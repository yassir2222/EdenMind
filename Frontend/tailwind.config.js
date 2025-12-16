/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{html,ts}",
  ],
  theme: {
    extend: {
      colors: {
        'eden-mint': '#34D399', // Bright mint button color (approx)
        'eden-mint-light': '#D1FAE5', // Light mint background
        'eden-mint-dark': '#059669', // Darker mint for hover
        'eden-blue': '#3B82F6', // Chat user bubble blue (approx)
        'eden-surface': '#F3F4F6', // Light gray background
        'eden-text': '#1F2937', // Dark gray text
        'eden-text-light': '#9CA3AF', // Light gray text
        // Keep previous for compatibility if needed, but prefer new ones
        'eden-light': '#F0F9FF',
        'eden-soothing': '#E0F2F1',
        'eden-primary': '#34D399',
        'eden-secondary': '#81C784',
        'eden-dark': '#1F2937',
      },
      fontFamily: {
        'sans': ['Inter', 'sans-serif'], // Assuming Inter or similiar
      },
      boxShadow: {
        'soft': '0 4px 20px -2px rgba(0, 0, 0, 0.05)',
      }
    },
  },
  plugins: [],
}
