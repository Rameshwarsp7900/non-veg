interface DateEditorModalProps {
  date: Date
  userId: string
  onClose: () => void
  onSave: () => void
}

export default function DateEditorModal({ date, userId, onClose, onSave }: DateEditorModalProps) {
  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        <h2 className="text-lg font-bold mb-4">
          Edit {date.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}
        </h2>
        
        <div className="space-y-4">
          <p className="text-gray-600">Date editor functionality coming soon...</p>
          
          <div className="flex justify-end space-x-3">
            <button
              onClick={onClose}
              className="px-4 py-2 text-gray-600 hover:text-gray-800"
            >
              Cancel
            </button>
            <button
              onClick={() => {
                onSave()
                onClose()
              }}
              className="px-4 py-2 bg-primary-600 text-white rounded hover:bg-primary-700"
            >
              Save
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}