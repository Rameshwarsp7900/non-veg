# 🗓️ Veg/Non-Veg Decision Calendar

**A modern web application for managing dietary choices based on Hindu traditions and personal preferences**

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fyourusername%2Fveg-nonveg-calendar)

## ✨ Features

- 📅 **Interactive Calendar** - Color-coded dietary status for each day
- 🕉️ **Hindu Traditions** - Pre-loaded festivals and observances
- 👥 **Multi-User Support** - Individual accounts with secure data
- 📱 **Responsive Design** - Works perfectly on all devices
- 🔒 **Secure Authentication** - Email-based registration and login
- 🗃️ **Database Integration** - Full CRUD operations with Supabase

## 🚀 Quick Deploy to Production

### Prerequisites
- Supabase account (free)
- Vercel account (free)
- 5 minutes of your time

### 1. Create Supabase Database
1. Go to [supabase.com](https://supabase.com) → \"New Project\"
2. In SQL Editor, paste contents of `supabase-schema.sql`
3. Click \"Run\" to create all tables
4. Copy Project URL and API Key from Settings → API

### 2. Deploy to Vercel
1. Push this code to GitHub
2. Import to [vercel.com](https://vercel.com)
3. Add environment variables:
   ```
   NEXT_PUBLIC_SUPABASE_URL=your_project_url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
   ```
4. Deploy!

### 3. Configure Authentication
1. In Supabase → Authentication → URL Configuration
2. Set Site URL: `https://your-app.vercel.app`
3. Add Redirect URL: `https://your-app.vercel.app/auth/callback`

## 🛠️ Local Development

```bash
# Install dependencies
npm install

# Set environment variables
cp .env.example .env.local
# Add your Supabase credentials

# Run development server
npm run dev
```

## 📦 Tech Stack

- **Framework**: Next.js 15 with App Router
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Deployment**: Vercel
- **Icons**: Lucide React

## 🎯 Core Features

### Calendar View
- 🟢 **Green** = Non-Veg OK
- 🔴 **Red** = Veg Only 
- 🟡 **Yellow** = Conditional
- Click dates for detailed information

### Hindu Traditions
- Major festivals (Ganesh Chaturthi, Navratri, Diwali)
- Weekly patterns (Tuesday/Saturday Hanuman days)
- Monthly observances (Ekadashi, Purnima)
- Eclipse-based restrictions

### User Management
- Secure email authentication
- Individual user calendars
- Profile customization
- Data privacy and security

## 📱 Screenshots

*[Add screenshots of your deployed app here]*

## 🔄 Roadmap

- [ ] AI Assistant for food questions
- [ ] Family group sharing
- [ ] Mobile app versions
- [ ] Recipe suggestions
- [ ] Push notifications
- [ ] Multi-language support

## 📄 License

MIT License - see [LICENSE](LICENSE) file

## 🤝 Contributing

Contributions welcome! Please read our contributing guidelines.

## 💬 Support

- Create an [issue](https://github.com/yourusername/veg-nonveg-calendar/issues)
- Email: support@vegnonvegcalendar.com

---

**Built with ❤️ for the Hindu community and traditional dietary practices**

*\"Ahimsa paramo dharma\"* - Non-violence is the highest virtue"