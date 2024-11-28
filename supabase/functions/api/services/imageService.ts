import { corsHeaders } from "../utils/cors.ts";

export async function uploadImage(supabase: any, req: Request) {
    try {
        const formData = await req.formData();
        const file = formData.get("file");

        if (!file) {
            throw new Error("No file uploaded");
        }

        if (!(file instanceof File)) {
            throw new Error("Invalid file type");
        }

        if (!file.type.includes("jpeg") && !file.type.includes("jpg")) {
            throw new Error("Only JPG/JPEG files are allowed");
        }

        const fileName = `${Date.now()}-${file.name}`;

        const { data, error } = await supabase
            .storage
            .from("protest")
            .upload(fileName, file, {
                contentType: file.type,
                cacheControl: "3600",
                upsert: false,
            });

        if (error) throw error;

        const { data: { publicUrl } } = supabase
            .storage
            .from("protest")
            .getPublicUrl(fileName);

        return new Response(
            JSON.stringify({
                fileName: fileName,
                publicUrl: publicUrl,
            }),
            {
                headers: { ...corsHeaders, "Content-Type": "application/json" },
                status: 200,
            },
        );
    } catch (error) {
        return new Response(
            JSON.stringify({
                error: error instanceof Error
                    ? error.message
                    : "Unknown error occurred",
            }),
            {
                headers: { ...corsHeaders, "Content-Type": "application/json" },
                status: 400,
            },
        );
    }
}
