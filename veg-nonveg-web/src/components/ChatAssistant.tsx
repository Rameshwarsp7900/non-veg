interface ChatAssistantProps {
  userId: string
}

export default function ChatAssistant({ userId }: ChatAssistantProps) {
  return (
    <div className="card">
      <div className="card-header">
        <h2 className="text-2xl font-bold text-gray-900">Food Assistant</h2>
        <p className="text-gray-600">Ask questions about your dietary restrictions</p>
      </div>
      
      <div className="text-center py-12">
        <div className="text-6xl mb-4">🤖</div>
        <h3 className="text-xl font-medium text-gray-900 mb-2">Coming Soon</h3>
        <p className="text-gray-600">
          AI assistant will be available soon. 
          Ask questions like "Can I eat chicken today?" and get instant answers.
        </p>
      </div>
    </div>
  )
}