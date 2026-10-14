import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// CORS
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};


// TYPE
interface CreateAdminRequest {
  email?: string;
  password?: string;
  nom?: string;
  prenom?: string;
  telephone?: string;
}


// RÉPONSE JSON
function jsonResponse(
  body: Record<string, unknown>,
  status: number,
): Response {
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


// EDGE FUNCTION
Deno.serve(async (req) => {

  //CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: corsHeaders,
    });
  }

  //MÉTHODE HTTP
  if (req.method !== "POST") {
    return jsonResponse(
      {
        success: false,
        message: "Méthode HTTP non autorisée.",
      },
      405,
    );
  }

  try {

    //VARIABLES SUPABASE
    const supabaseUrl =
      Deno.env.get("SUPABASE_URL");

    const supabaseAnonKey =
      Deno.env.get("SUPABASE_ANON_KEY");

    const serviceRoleKey =
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (
      !supabaseUrl ||
      !supabaseAnonKey ||
      !serviceRoleKey
    ) {
      console.error(
        "Configuration Supabase incomplète.",
      );

      return jsonResponse(
        {
          success: false,
          message:
            "Configuration Supabase incomplète.",
        },
        500,
      );
    }


    //RÉCUPÉRER LE JWT
    const authHeader =
      req.headers.get("Authorization");

    if (!authHeader) {
      return jsonResponse(
        {
          success: false,
          message:
            "Authentification requise.",
        },
        401,
      );
    }

   //CLIENT UTILISATEUR
    const supabaseUser =
      createClient(
        supabaseUrl,
        supabaseAnonKey,
        {
          global: {
            headers: {
              Authorization:
                authHeader,
            },
          },
        },
      );


    //VÉRIFIER LE JWT
    const {
      data: {
        user: currentUser,
      },
      error: userError,
    } =
      await supabaseUser.auth.getUser();

    if (
      userError ||
      !currentUser
    ) {
      console.error(
        "Session utilisateur invalide:",
        userError,
      );

      return jsonResponse(
        {
          success: false,
          message:
            "Session utilisateur invalide.",
        },
        401,
      );
    }


    //CLIENT SERVICE ROLE
    const supabaseAdmin =
      createClient(
        supabaseUrl,
        serviceRoleKey,
        {
          auth: {
            autoRefreshToken: false,
            persistSession: false,
          },
        },
      );


    //RÉCUPÉRER LE DEMANDEUR
    const {
      data: requester,
      error: requesterError,
    } =
      await supabaseAdmin
        .from("users")
        .select(
          "id, email, role, statut",
        )
        .eq(
          "id",
          currentUser.id,
        )
        .maybeSingle();

    if (requesterError) {
      console.error(
        "Erreur récupération demandeur:",
        requesterError,
      );

      return jsonResponse(
        {
          success: false,
          message:
            "Impossible de vérifier les autorisations.",
        },
        500,
      );
    }


    //PROFIL INTROUVABLE
    if (!requester) {
      return jsonResponse(
        {
          success: false,
          message:
            "Profil administrateur introuvable.",
        },
        403,
      );
    }


    //NORMALISER LE RÔLE
    const requesterRole =
      String(
        requester.role ?? "",
      )
        .trim()
        .toLowerCase();


    //VÉRIFIER ADMIN / SUPER_ADMIN
    if (
      requesterRole !== "admin" &&
      requesterRole !== "super_admin"
    ) {
      return jsonResponse(
        {
          success: false,
          message:
            "Vous n'avez pas l'autorisation de créer un administrateur.",
        },
        403,
      );
    }

    // 11. VÉRIFIER LE STATUT
    if (
      requester.statut !== "actif"
    ) {
      return jsonResponse(
        {
          success: false,
          message:
            "Votre compte administrateur n'est pas actif.",
        },
        403,
      );
    }


    //LIRE LE BODY
    let body: CreateAdminRequest;

    try {
      body = await req.json();
    } catch (error) {
      console.error(
        "Erreur JSON:",
        error,
      );

      return jsonResponse(
        {
          success: false,
          message:
            "Données JSON invalides.",
        },
        400,
      );
    }


    //DONNÉES DU NOUVEL ADMIN
    const email =
      String(
        body.email ?? "",
      )
        .trim()
        .toLowerCase();

    const password =
      String(
        body.password ?? "",
      );

    const nom =
      String(
        body.nom ?? "",
      )
        .trim();

    const prenom =
      String(
        body.prenom ?? "",
      )
        .trim();

    const telephone =
      String(
        body.telephone ?? "",
      )
        .trim();


    //CHAMPS OBLIGATOIRES
    if (
      !email ||
      !password ||
      !nom ||
      !prenom
    ) {
      return jsonResponse(
        {
          success: false,
          message:
            "Email, mot de passe, nom et prénom sont obligatoires.",
        },
        400,
      );
    }


    // VALIDATION EMAIL
    const emailRegex =
      /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (
      !emailRegex.test(email)
    ) {
      return jsonResponse(
        {
          success: false,
          message:
            "Adresse email invalide.",
        },
        400,
      );
    }


    //VALIDATION NOM
    if (
      nom.length < 2 ||
      nom.length > 100
    ) {
      return jsonResponse(
        {
          success: false,
          message:
            "Le nom doit contenir entre 2 et 100 caractères.",
        },
        400,
      );
    }


    //VALIDATION PRÉNOM
    if (
      prenom.length < 2 ||
      prenom.length > 100
    ) {
      return jsonResponse(
        {
          success: false,
          message:
            "Le prénom doit contenir entre 2 et 100 caractères.",
        },
        400,
      );
    }


    //VALIDATION TÉLÉPHONE
    if (telephone.length > 0) {
      const phoneRegex =
        /^[0-9+\-() ]{8,20}$/;

      if (
        !phoneRegex.test(
          telephone,
        )
      ) {
        return jsonResponse(
          {
            success: false,
            message:
              "Numéro de téléphone invalide.",
          },
          400,
        );
      }
    }


    //VALIDATION MOT DE PASSE
    //Admin 12 caractères minimum, majuscule, minuscule, chiffre, caractère spécial
    if (
      password.length < 12
    ) {
      return jsonResponse(
        {
          success: false,
          message:
            "Le mot de passe administrateur doit contenir au moins 12 caractères.",
        },
        400,
      );
    }

    if (
      !/[A-Z]/.test(password)
    ) {
      return jsonResponse(
        {
          success: false,
          message:
            "Le mot de passe doit contenir au moins une majuscule.",
        },
        400,
      );
    }

    if (
      !/[a-z]/.test(password)
    ) {
      return jsonResponse(
        {
          success: false,
          message:
            "Le mot de passe doit contenir au moins une minuscule.",
        },
        400,
      );
    }

    if (
      !/[0-9]/.test(password)
    ) {
      return jsonResponse(
        {
          success: false,
          message:
            "Le mot de passe doit contenir au moins un chiffre.",
        },
        400,
      );
    }

    if (
      !/[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\/'`;~]/
        .test(password)
    ) {
      return jsonResponse(
        {
          success: false,
          message:
            "Le mot de passe doit contenir au moins un caractère spécial.",
        },
        400,
      );
    }


    //VÉRIFIER EMAIL DANS public.users
    const {
      data: existingProfile,
      error: existingProfileError,
    } =
      await supabaseAdmin
        .from("users")
        .select(
          "id, email, role",
        )
        .eq(
          "email",
          email,
        )
        .maybeSingle();

    if (
      existingProfileError
    ) {
      console.error(
        "Erreur vérification email:",
        existingProfileError,
      );

      return jsonResponse(
        {
          success: false,
          message:
            "Impossible de vérifier l'adresse email.",
        },
        500,
      );
    }

    if (existingProfile) {
      return jsonResponse(
        {
          success: false,
          message:
            "Un utilisateur existe déjà avec cette adresse email.",
        },
        409,
      );
    }

    //CRÉER LE COMPTE AUTH
    const {
      data: createdAuth,
      error: createAuthError,
    } =
      await supabaseAdmin.auth.admin.createUser({
        email,
        password,
        email_confirm: true,

        user_metadata: {
          nom,
          prenom,
          telephone,

          // Sécurité :
          role: "locataire",
        },
      });


    //ÉCHEC CRÉATION AUTH
    if (
      createAuthError ||
      !createdAuth.user
    ) {
      console.error(
        "Erreur création Auth:",
        createAuthError,
      );

      return jsonResponse(
        {
          success: false,
          message:
            createAuthError?.message ??
            "Impossible de créer le compte.",
        },
        500,
      );
    }

    const newUserId =
      createdAuth.user.id;

    //VÉRIFIER LE PROFIL CRÉÉ PAR handle_new_user
    const {
      data: createdProfile,
      error: createdProfileError,
    } =
      await supabaseAdmin
        .from("users")
        .select(
          "id, email, nom, prenom, telephone, role, statut",
        )
        .eq(
          "id",
          newUserId,
        )
        .maybeSingle();

    if (
      createdProfileError ||
      !createdProfile
    ) {
      console.error(
        "Profil public.users introuvable:",
        createdProfileError,
      );


      // ROLLBACK AUTH
      const {
        error: rollbackError,
      } =
        await supabaseAdmin.auth.admin.deleteUser(
          newUserId,
        );

      if (rollbackError) {
        console.error(
          "Erreur rollback Auth:",
          rollbackError,
        );
      }

      return jsonResponse(
        {
          success: false,
          message:
            "Le compte Auth a été créé mais le profil utilisateur n'a pas été créé.",
        },
        500,
      );
    }


    //PROMOTION EN ADMIN
    const {
      data: updatedProfile,
      error: updateProfileError,
    } =
      await supabaseUser.rpc(
        "creer_administrateur",
        {
          p_user_id:
            newUserId,

          p_email:
            email,

          p_nom:
            nom,

          p_prenom:
            prenom,

          p_telephone:
            telephone,
        },
      );


    //ÉCHEC PROMOTION
    if (
      updateProfileError ||
      !updatedProfile
    ) {
      console.error(
        "Erreur promotion administrateur:",
        updateProfileError,
      );


      // ROLLBACK AUTH
      const {
        error: rollbackError,
      } =
        await supabaseAdmin.auth.admin.deleteUser(
          newUserId,
        );

      if (rollbackError) {
        console.error(
          "Erreur rollback Auth:",
          rollbackError,
        );
      }

      return jsonResponse(
        {
          success: false,
          message:
            updateProfileError?.message ??
            "Le compte Auth a été créé mais le profil administrateur n'a pas pu être configuré.",
        },
        500,
      );
    }

    //VÉRIFICATION FINALE DU RÔLE
    if (
      updatedProfile.role !==
      "admin"
    ) {
      console.error(
        "Rôle final inattendu:",
        updatedProfile.role,
      );

      //ROLLBACK AUTH
      const {
        error: rollbackError,
      } =
        await supabaseAdmin.auth.admin.deleteUser(
          newUserId,
        );

      if (rollbackError) {
        console.error(
          "Erreur rollback Auth:",
          rollbackError,
        );
      }

      return jsonResponse(
        {
          success: false,
          message:
            "La création de l'administrateur n'a pas pu être finalisée.",
        },
        500,
      );
    }

    //RÉPONSE FINALE
    return jsonResponse(
      {
        success: true,

        message:
          "Administrateur créé avec succès.",

        user: {
          id:
            updatedProfile.id,

          email:
            updatedProfile.email,

          nom:
            updatedProfile.nom,

          prenom:
            updatedProfile.prenom,

          telephone:
            updatedProfile.telephone,

          role:
            updatedProfile.role,

          statut:
            updatedProfile.statut,
        },
      },
      201,
    );

  } catch (error) {


    //ERREUR GÉNÉRALE
    console.error(
      "Erreur create-admin:",
      error,
    );

    return jsonResponse(
      {
        success: false,

        message:
          error instanceof Error
            ? error.message
            : "Une erreur est survenue.",
      },
      500,
    );
  }
});