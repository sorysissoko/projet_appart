import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY =
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabaseAdmin = createClient(
  SUPABASE_URL,
  SUPABASE_SERVICE_ROLE_KEY,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  },
);

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(
  body: Record<string, unknown>,
  status = 200,
) {
  return new Response(
    JSON.stringify(body),
    {
      status,
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json",
      },
    },
  );
}

Deno.serve(async (req: Request) => {
  try {
    // ==========================================================
    // OPTIONS / CORS
    // ==========================================================

    if (req.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: corsHeaders,
      });
    }

    // ==========================================================
    // MÉTHODE HTTP
    // ==========================================================

    if (req.method !== "POST") {
      return jsonResponse(
        {
          success: false,
          error: "Méthode HTTP non autorisée.",
        },
        405,
      );
    }

    // ==========================================================
    // AUTHORIZATION
    // ==========================================================

    const authorization =
      req.headers.get("Authorization");

    if (!authorization) {
      return jsonResponse(
        {
          success: false,
          error: "Authorization obligatoire.",
        },
        401,
      );
    }

    const token =
      authorization.replace(/^Bearer\s+/i, "").trim();

    if (!token) {
      return jsonResponse(
        {
          success: false,
          error: "Token JWT invalide.",
        },
        401,
      );
    }

    // ==========================================================
    // UTILISATEUR CONNECTÉ
    // ==========================================================

    const {
      data: {
        user,
      },
      error: userError,
    } = await supabaseAdmin.auth.getUser(token);

    if (userError || !user) {
      console.error(
        "AUTH ERROR :",
        userError,
      );

      return jsonResponse(
        {
          success: false,
          error: "Utilisateur non authentifié.",
        },
        401,
      );
    }

    console.log(
      "👤 Utilisateur authentifié :",
      user.id,
    );

    // ==========================================================
    // BODY
    // ==========================================================

    let body: Record<string, unknown>;

    try {
      body = await req.json();
    } catch {
      return jsonResponse(
        {
          success: false,
          error: "Corps JSON invalide.",
        },
        400,
      );
    }

    const paiementId =
      typeof body.paiement_id === "string"
        ? body.paiement_id.trim()
        : "";

    if (!paiementId) {
      return jsonResponse(
        {
          success: false,
          error: "paiement_id obligatoire.",
        },
        400,
      );
    }

    console.log(
      "💳 Paiement demandé :",
      paiementId,
    );

    // ==========================================================
    // RÉCUPÉRER LE PAIEMENT
    // ==========================================================

    const {
      data: paiement,
      error: paiementError,
    } = await supabaseAdmin
      .from("paiements")
      .select(`
        id,
        reservation_id,
        locataire_id,
        proprietaire_id,
        appartement_id,
        paiement_parent_id,
        type_paiement,
        methode_paiement,
        montant_attendu,
        montant,
        montant_proprietaire,
        frais_service,
        statut,
        provider,
        provider_transaction_id,
        reference_transaction,
        provider_payment_method_id,
        description,
        metadata
      `)
      .eq("id", paiementId)
      .maybeSingle();

    if (paiementError) {
      console.error(
        "ERREUR LECTURE PAIEMENT :",
        paiementError,
      );

      return jsonResponse(
        {
          success: false,
          error: "Impossible de récupérer le paiement.",
        },
        500,
      );
    }

    if (!paiement) {
      return jsonResponse(
        {
          success: false,
          error: "Paiement introuvable.",
        },
        404,
      );
    }

    // ==========================================================
    // VÉRIFIER LE PROPRIÉTAIRE DU PAIEMENT
    // ==========================================================

    if (paiement.locataire_id !== user.id) {
      return jsonResponse(
        {
          success: false,
          error:
            "Vous n'êtes pas autorisé à payer ce paiement.",
        },
        403,
      );
    }

    // ==========================================================
    // IDEMPOTENCE
    // ==========================================================

    if (paiement.statut === "confirme") {
      return jsonResponse({
        success: true,
        already_confirmed: true,
        paiement_id: paiement.id,
        reservation_id: paiement.reservation_id,
        statut: paiement.statut,
        montant: paiement.montant,
        provider_transaction_id:
          paiement.provider_transaction_id,
      });
    }

    // ==========================================================
    // STATUT AUTORISÉ
    // ==========================================================

    if (
      paiement.statut !== "en_attente" &&
      paiement.statut !== "en_cours"
    ) {
      return jsonResponse(
        {
          success: false,
          error:
            `Ce paiement ne peut pas être lancé. ` +
            `Statut actuel : ${paiement.statut}`,
        },
        409,
      );
    }

    // ==========================================================
    // MONTANT
    // ==========================================================

    const montantAttendu =
      Number(paiement.montant_attendu);

    if (
      !Number.isFinite(montantAttendu) ||
      montantAttendu <= 0
    ) {
      return jsonResponse(
        {
          success: false,
          error:
            "Le montant attendu du paiement est invalide.",
        },
        400,
      );
    }

    // ==========================================================
    // VÉRIFICATION FINANCIÈRE
    // ==========================================================

    const proprietaire =
      Number(paiement.montant_proprietaire);

    const fraisService =
      Number(paiement.frais_service);

    if (
      !Number.isFinite(proprietaire) ||
      !Number.isFinite(fraisService)
    ) {
      return jsonResponse(
        {
          success: false,
          error:
            "Répartition financière invalide.",
        },
        400,
      );
    }

    const repartition =
      Math.round(
        (proprietaire + fraisService) * 100,
      ) / 100;

    const attendu =
      Math.round(montantAttendu * 100) / 100;

    if (repartition !== attendu) {
      return jsonResponse(
        {
          success: false,
          error:
            "La répartition du paiement est incohérente.",
        },
        400,
      );
    }

    // ==========================================================
    // RÉCUPÉRER LA RÉSERVATION
    // ==========================================================

    const {
      data: reservation,
      error: reservationError,
    } = await supabaseAdmin
      .from("reservations")
      .select(`
        id,
        appartement_id,
        locataire_id,
        proprietaire_id,
        statut,
        prix_total,
        prix_proprietaire,
        frais_service,
        how_to_pay,
        methode_paiement,
        acompte
      `)
      .eq("id", paiement.reservation_id)
      .maybeSingle();

    if (reservationError) {
      console.error(
        "ERREUR RÉSERVATION :",
        reservationError,
      );

      return jsonResponse(
        {
          success: false,
          error:
            "Impossible de récupérer la réservation.",
        },
        500,
      );
    }

    if (!reservation) {
      return jsonResponse(
        {
          success: false,
          error: "Réservation introuvable.",
        },
        404,
      );
    }

    // ==========================================================
    // VÉRIFICATION LOCATAIRE
    // ==========================================================

    if (reservation.locataire_id !== user.id) {
      return jsonResponse(
        {
          success: false,
          error:
            "Cette réservation ne vous appartient pas.",
        },
        403,
      );
    }

    // ==========================================================
    // VÉRIFICATION DU STATUT RÉSERVATION
    // ==========================================================

    if (
      reservation.statut !==
        "en_attente_paiement" &&
      reservation.statut !==
        "confirmee"
    ) {
      return jsonResponse(
        {
          success: false,
          error:
            `La réservation n'est pas dans un état ` +
            `permettant ce paiement : ${reservation.statut}`,
        },
        409,
      );
    }

    // ==========================================================
    // MÉTHODE DE PAIEMENT
    // ==========================================================

    const methodesAutorisees = [
      "orange_money",
      "moov_money",
      "wave",
      "carte_bancaire",
    ];

    if (
      !methodesAutorisees.includes(
        paiement.methode_paiement,
      )
    ) {
      return jsonResponse(
        {
          success: false,
          error:
            "Méthode de paiement non supportée.",
        },
        400,
      );
    }

    // ==========================================================
    // PASSAGE EN COURS
    // ==========================================================
    /*
       Nous faisons d'abord une mise à jour conditionnelle.

       Cela évite qu'un deuxième appel simultané puisse
       facilement démarrer deux paiements.
    */

    if (paiement.statut === "en_attente") {
      const {
        data: updatedPaiement,
        error: updateError,
      } = await supabaseAdmin
        .from("paiements")
        .update({
          statut: "en_cours",
          updated_at: new Date().toISOString(),
        })
        .eq("id", paiement.id)
        .eq("statut", "en_attente")
        .select(`
          id,
          statut,
          montant_attendu,
          methode_paiement
        `)
        .maybeSingle();

      if (updateError) {
        console.error(
          "ERREUR PASSAGE EN COURS :",
          updateError,
        );

        return jsonResponse(
          {
            success: false,
            error:
              "Impossible de démarrer le paiement.",
          },
          500,
        );
      }

      if (!updatedPaiement) {
        return jsonResponse(
          {
            success: false,
            error:
              "Le paiement est déjà en cours de traitement.",
          },
          409,
        );
      }
    }

    // ==========================================================
    // PROVIDER DE TEST
    // ==========================================================
    /*
       ATTENTION :

       CE PROVIDER EST UNIQUEMENT POUR NOS TESTS.

       Aucun argent réel n'est débité.

       Plus tard nous remplacerons cette partie par
       Orange Money / Moov Money / Wave / carte.
    */

    const timestamp = Date.now();

    const provider =
      `test_${paiement.methode_paiement}`;

    const providerTransactionId =
      `TEST_${paiement.id}_${timestamp}`;

    const referenceTransaction =
      `ADS-TEST-${timestamp}`;

    const paymentUrl =
      `https://example.com/test-payment/${paiement.id}`;

    const metadata = {
      ...(paiement.metadata ?? {}),
      environment: "test",
      simulated: true,
      test_payment: true,
      created_by: "create-payment",
      created_at: new Date().toISOString(),
    };

    // ==========================================================
    // ENREGISTRER LA TRANSACTION PROVIDER
    // ==========================================================

    const {
      data: paymentUpdate,
      error: paymentUpdateError,
    } = await supabaseAdmin
      .from("paiements")
      .update({
        provider,
        provider_transaction_id:
          providerTransactionId,
        reference_transaction:
          referenceTransaction,
        metadata,
        updated_at:
          new Date().toISOString(),
      })
      .eq("id", paiement.id)
      .eq("statut", "en_cours")
      .select(`
        id,
        reservation_id,
        statut,
        montant_attendu,
        montant_proprietaire,
        frais_service,
        methode_paiement,
        provider,
        provider_transaction_id,
        reference_transaction
      `)
      .maybeSingle();

    if (paymentUpdateError) {
      console.error(
        "ERREUR ENREGISTREMENT TRANSACTION :",
        paymentUpdateError,
      );

      // Retour à en_attente pour permettre
      // une nouvelle tentative.
      await supabaseAdmin
        .from("paiements")
        .update({
          statut: "en_attente",
          message_erreur:
            "Impossible d'enregistrer la transaction test.",
        })
        .eq("id", paiement.id)
        .eq("statut", "en_cours");

      return jsonResponse(
        {
          success: false,
          error:
            "Impossible d'enregistrer la transaction.",
        },
        500,
      );
    }

    if (!paymentUpdate) {
      return jsonResponse(
        {
          success: false,
          error:
            "Le paiement n'est plus disponible pour traitement.",
        },
        409,
      );
    }

    // ==========================================================
    // RÉPONSE
    // ==========================================================

    return jsonResponse({
      success: true,

      test_mode: true,

      message:
        "Paiement de test créé avec succès.",

      paiement_id:
        paymentUpdate.id,

      reservation_id:
        paymentUpdate.reservation_id,

      statut:
        paymentUpdate.statut,

      montant_attendu:
        paymentUpdate.montant_attendu,

      montant_proprietaire:
        paymentUpdate.montant_proprietaire,

      frais_service:
        paymentUpdate.frais_service,

      methode_paiement:
        paymentUpdate.methode_paiement,

      provider:
        paymentUpdate.provider,

      provider_transaction_id:
        paymentUpdate.provider_transaction_id,

      reference_transaction:
        paymentUpdate.reference_transaction,

      payment_url:
        paymentUrl,

      next_step:
        "Appelez webhook-payment avec la transaction de test.",
    });
  } catch (error) {
    console.error(
      "❌ ERREUR CREATE-PAYMENT :",
      error,
    );

    return jsonResponse(
      {
        success: false,
        error:
          error instanceof Error
            ? error.message
            : String(error),
      },
      500,
    );
  }
});