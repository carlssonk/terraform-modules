// Cloudflare Worker for feature-flag based routing
// This worker fetches a specific version of the website based on ConfigCat feature flags

addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  try {
    // Initialize ConfigCat client
    const configCatApiKey = CONFIGCAT_API_KEY; // This will be injected as a secret binding
    
    // Create user object for feature flag evaluation
    // You can customize this based on your needs (e.g., IP, cookies, headers)
    const user = {
      identifier: request.headers.get('CF-Connecting-IP') || 'anonymous',
      custom: {
        userAgent: request.headers.get('User-Agent') || '',
      }
    };

    // Fetch feature flag value from ConfigCat
    // Note: In production, you'd use the ConfigCat SDK or API
    const hash = await getConfigCatValue('website_hash', 'abc123def', user, configCatApiKey);

    // Construct the S3 URL with the hash prefix
    const url = new URL(request.url);
    const originalHostname = url.hostname;
    const bucketName = S3_BUCKET_NAME; // This will be injected as a plain text binding
    
    url.hostname = `${bucketName}.s3.amazonaws.com`;
    url.pathname = `/${hash}${url.pathname}`;

    // Fetch the content from S3
    const response = await fetch(url, {
      method: request.method,
      headers: request.headers,
    });

    // Create a new response with modified headers
    const newResponse = new Response(response.body, response);
    
    // Add CORS headers if needed
    newResponse.headers.set('Access-Control-Allow-Origin', '*');
    
    // Add custom header to indicate which version is being served
    newResponse.headers.set('X-Website-Version', hash);
    
    return newResponse;
  } catch (error) {
    // Return error response
    return new Response(`Worker error: ${error.message}`, {
      status: 500,
      headers: {
        'Content-Type': 'text/plain',
      },
    });
  }
}

async function getConfigCatValue(key, defaultValue, user, apiKey) {
  // Simple ConfigCat API integration
  // For production, consider using the ConfigCat JS SDK or caching
  try {
    const configCatUrl = `https://cdn-global.configcat.com/configuration-files/${apiKey}/config_v5.json`;
    const response = await fetch(configCatUrl);
    
    if (!response.ok) {
      console.error('ConfigCat API error:', response.status);
      return defaultValue;
    }
    
    const config = await response.json();
    
    // Simple evaluation logic - you may need to adjust based on your ConfigCat setup
    // This is a simplified version; the real SDK does complex targeting
    const setting = config.f?.[key];
    if (setting && setting.v) {
      return setting.v.s || defaultValue;
    }
    
    return defaultValue;
  } catch (error) {
    console.error('Error fetching ConfigCat value:', error);
    return defaultValue;
  }
}

