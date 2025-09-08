export default function NotFound() {
  return (
    <div className=\"min-h-screen flex items-center justify-center bg-gray-50\">
      <div className=\"max-w-md w-full text-center p-8\">
        <div className=\"text-6xl mb-4\">📅</div>
        <h2 className=\"text-2xl font-bold text-gray-900 mb-4\">
          Page Not Found
        </h2>
        <p className=\"text-gray-600 mb-6\">
          Sorry, we couldn't find the page you're looking for.
        </p>
        <a
          href=\"/\"
          className=\"inline-flex items-center justify-center rounded-md bg-primary-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2\"
        >
          Go back home
        </a>
      </div>
    </div>
  )
}