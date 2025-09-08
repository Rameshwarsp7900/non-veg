'use client'

import { useEffect } from 'react'
import { Button } from '@/components/ui/Button'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    // Log the error to an error reporting service
    console.error('Application error:', error)
  }, [error])

  return (
    <div className=\"min-h-screen flex items-center justify-center bg-gray-50\">
      <div className=\"max-w-md w-full text-center p-8\">
        <div className=\"text-6xl mb-4\">⚠️</div>
        <h2 className=\"text-2xl font-bold text-gray-900 mb-4\">
          Something went wrong!
        </h2>
        <p className=\"text-gray-600 mb-6\">
          We apologize for the inconvenience. Please try refreshing the page.
        </p>
        <div className=\"space-y-4\">
          <Button
            onClick={reset}
            className=\"w-full\"
          >
            Try again
          </Button>
          <Button
            variant=\"outline\"
            onClick={() => window.location.href = '/'}
            className=\"w-full\"
          >
            Go to homepage
          </Button>
        </div>
        {process.env.NODE_ENV === 'development' && (
          <details className=\"mt-6 text-left\">
            <summary className=\"cursor-pointer text-sm text-gray-500\">
              Error details (development only)
            </summary>
            <pre className=\"mt-2 text-xs bg-gray-100 p-4 rounded overflow-auto\">
              {error.message}
            </pre>
          </details>
        )}
      </div>
    </div>
  )
}