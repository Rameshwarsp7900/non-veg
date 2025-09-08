#!/bin/bash

# Production Deployment Script
echo \"🚀 Deploying Veg/Non-Veg Calendar to Production...\"

# Check if required files exist
if [ ! -f \"package.json\" ]; then
    echo \"❌ Error: Not in project directory\"
    exit 1
fi

echo \"✅ Building production version...\"
npm run build

if [ $? -eq 0 ]; then
    echo \"✅ Build successful!\"
    echo \"📦 Ready for Vercel deployment\"
    echo \"\"
    echo \"Next steps:\"
    echo \"1. Push to GitHub\"
    echo \"2. Import to Vercel\"
    echo \"3. Add Supabase environment variables\"
    echo \"4. Deploy!\"
else
    echo \"❌ Build failed - check errors above\"
    exit 1
fi