export default function Loading() {
  return (
    <div className=\"min-h-screen flex items-center justify-center bg-gray-50\">
      <div className=\"text-center\">
        <div className=\"animate-spin rounded-full h-16 w-16 border-b-4 border-primary-600 mx-auto mb-4\"></div>
        <div className=\"text-lg font-medium text-gray-900 mb-2\">
          Loading your calendar...
        </div>
        <div className=\"text-sm text-gray-600\">
          Please wait while we prepare your dietary information
        </div>
      </div>
    </div>
  )
}