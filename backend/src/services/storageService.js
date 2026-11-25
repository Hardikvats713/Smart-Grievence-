// Storage Service handling Supabase Private Storage Buckets & Signed URLs
const supabase = require('../config/supabase');
const config = require('../config/env');

async function getSignedUrl(bucket, filePath, expiresInSeconds = 900) {
  if (!supabase) {
    // Development fallback: return placeholder or base64 URL
    return filePath.startsWith('http') || filePath.startsWith('data:') 
      ? filePath 
      : `http://localhost:${config.PORT}/uploads/${filePath}`;
  }

  try {
    const { data, error } = await supabase.storage
      .from(bucket)
      .createSignedUrl(filePath, expiresInSeconds);

    if (error) {
      console.warn(`[Storage] Failed to generate signed URL for ${filePath}:`, error.message);
      return filePath;
    }
    return data.signedUrl;
  } catch (err) {
    console.error('[Storage] Error:', err.message);
    return filePath;
  }
}

async function uploadFile(bucket, filePath, fileBuffer, mimeType) {
  if (!supabase) {
    return { path: filePath, bucket };
  }

  const { data, error } = await supabase.storage
    .from(bucket)
    .upload(filePath, fileBuffer, {
      contentType: mimeType,
      upsert: true
    });

  if (error) {
    throw new Error(`Upload failed: ${error.message}`);
  }
  return data;
}

module.exports = {
  getSignedUrl,
  uploadFile
};
