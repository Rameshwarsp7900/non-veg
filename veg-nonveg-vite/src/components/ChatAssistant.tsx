interface ChatAssistantProps {
  userId: string
}

export default function ChatAssistant({ userId }: ChatAssistantProps) {
  return (
    <div className="card">
      <h2 className="text-2xl font-bold text-gray-900 mb-6">AI Chat Assistant</h2>
      <div className="text-center text-gray-600 py-12">
        <p className="text-lg mb-4">AI chat assistant coming soon...</p>
        <p className="text-sm">Here you'll be able to ask questions about dietary restrictions and get personalized advice.</p>
      </div>
    </div>
  )
}