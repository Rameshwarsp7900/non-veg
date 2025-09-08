# Deployment Guide - Veg/Non-Veg Calendar Web App

## 🚀 Quick Deployment to Vercel

### Prerequisites
- Node.js 18+ installed
- Vercel account (free)
- Supabase account (free)

### Step 1: Set up Supabase Database

1. **Create a Supabase Project**
   - Go to [supabase.com](https://supabase.com)
   - Click "Start your project"
   - Create a new project
   - Choose a region (preferably close to your users)

2. **Run the Database Schema**
   - Go to your Supabase dashboard
   - Navigate to SQL Editor
   - Copy and paste the contents of `supabase-schema.sql`
   - Click "Run" to create all tables and policies

3. **Get Your Supabase Credentials**
   - Go to Settings > API
   - Copy your Project URL and Anon Public Key
   - Save these for environment variables

### Step 2: Deploy to Vercel

1. **Push to GitHub**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/yourusername/veg-nonveg-calendar.git
   git push -u origin main
   ```

2. **Deploy with Vercel**
   - Go to [vercel.com](https://vercel.com)
   - Click "Import Project"
   - Connect your GitHub repository
   - Configure environment variables:

   **Environment Variables:**
   ```
   NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

3. **Deploy**
   - Click "Deploy"
   - Vercel will automatically build and deploy your app
   - You'll get a live URL like `https://your-app.vercel.app`

### Step 3: Configure Authentication

1. **Set up Supabase Auth**
   - In Supabase dashboard, go to Authentication > Settings
   - Add your Vercel URL to "Site URL"
   - Add your Vercel URL to "Redirect URLs":
     - `https://your-app.vercel.app/auth/callback`

2. **Enable Email Authentication**
   - In Authentication > Settings
   - Enable "Email" provider
   - Configure email templates if needed

### Step 4: Test Your Deployment

1. Visit your Vercel URL
2. Sign up with an email
3. Check email for confirmation link
4. Sign in and test the calendar functionality

## 🔧 Local Development

### Setup
```bash
# Clone the repository
git clone https://github.com/yourusername/veg-nonveg-calendar.git
cd veg-nonveg-web

# Install dependencies
npm install

# Copy environment variables
cp .env.example .env.local

# Add your Supabase credentials to .env.local
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key

# Run development server
npm run dev
```

### Available Scripts
- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run lint` - Run ESLint

## 📦 Features Included

### ✅ Current Features
- **User Authentication** - Email/password with Supabase Auth
- **Calendar View** - Interactive calendar with color-coded dates
- **Today's Status** - Prominent display of current dietary status
- **Responsive Design** - Works on desktop and mobile
- **Database Integration** - Full CRUD operations with Supabase

### 🔄 In Development
- **Event Management** - Add/edit festivals and special days
- **Weekly Rules** - Set recurring dietary patterns
- **AI Assistant** - Chat interface for food questions
- **Family Sync** - Share rules with family members

## 🌟 Advanced Configuration

### Custom Domain
1. Add your domain in Vercel dashboard
2. Update Supabase redirect URLs
3. Configure DNS records

### Email Configuration
1. Set up custom SMTP in Supabase
2. Configure email templates
3. Add brand customization

### Performance Optimization
- Images are optimized with Next.js Image component
- Database queries use indexing
- RLS policies ensure security
- Caching implemented for better performance

## 🔒 Security Features

- **Row Level Security** - Users can only access their own data
- **Email Verification** - Required for account activation
- **Secure Authentication** - Handled by Supabase
- **Input Validation** - All forms validate user input
- **CSRF Protection** - Built into Next.js

## 📱 Multi-User Support

The app supports multiple users with:
- **Individual Calendars** - Each user has their own events and rules
- **Family Groups** - Share rules with family members
- **User Profiles** - Customizable user settings
- **Privacy** - Users can only see their own data

## 🎯 Next Steps

After deployment, you can:
1. **Add OpenAI Integration** - For enhanced AI chat functionality
2. **Mobile App** - Convert to React Native or Flutter
3. **Push Notifications** - Real-time alerts for events
4. **Advanced Features** - Recipe suggestions, community features

## 💡 Tips

- Monitor your Supabase usage in the dashboard
- Set up database backups for production
- Use Vercel Analytics to track user engagement
- Consider upgrading to paid plans for higher limits

## 🆘 Troubleshooting

### Common Issues
1. **Authentication not working** - Check redirect URLs in Supabase
2. **Database errors** - Verify schema was created correctly
3. **Environment variables** - Ensure all variables are set in Vercel
4. **Build errors** - Check Node.js version compatibility

### Support
- Check the [Supabase documentation](https://supabase.com/docs)
- Review [Vercel deployment guides](https://vercel.com/docs)
- Create an issue in the GitHub repository

---

**Your Veg/Non-Veg Calendar is now live! 🎉**

Share the URL with family and friends to help them manage their dietary choices based on traditions and preferences.