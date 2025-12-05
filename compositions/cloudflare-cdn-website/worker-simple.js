// Simple Cloudflare Worker for feature-flag based routing
// This is a simplified version without ConfigCat integration

addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  try {
    // Get version from cookie, header, or use default
    const version = getVersion(request);

    // Construct the S3 URL with the version prefix
    const url = new URL(request.url);
    const bucketName = S3_BUCKET_NAME;
    
    url.hostname = `${bucketName}.s3.amazonaws.com`;
    url.pathname = `/${version}${url.pathname}`;

    // Fetch the content from S3
    const response = await fetch(url, {
      method: request.method,
      headers: request.headers,
    });

    // Create a new response with modified headers
    const newResponse = new Response(response.body, response);
    
    // Add custom header to indicate which version is being served
    newResponse.headers.set('X-Website-Version', version);
    
    return newResponse;
  } catch (error) {
    return new Response(`Worker error: ${error.message}`, {
      status: 500,
      headers: {
        'Content-Type': 'text/plain',
      },
    });
  }
}

function getVersion(request) {
  // Check for version in cookie
  const cookies = request.headers.get('Cookie') || '';
  const versionMatch = cookies.match(/version=([^;]+)/);
  if (versionMatch) {
    return versionMatch[1];
  }

  // Check for version in query parameter
  const url = new URL(request.url);
  const queryVersion = url.searchParams.get('version');
  if (queryVersion) {
    return queryVersion;
  }

  // Check for version in custom header
  const headerVersion = request.headers.get('X-Website-Version');
  if (headerVersion) {
    return headerVersion;
  }

  // Default version
  return DEFAULT_HASH || 'production';
}

