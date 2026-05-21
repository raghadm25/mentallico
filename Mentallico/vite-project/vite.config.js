import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      /**
       * Forward every /api/* request from the Vite dev server
       * to the Django backend running on port 8000.
       *
       * This eliminates CORS preflight issues in development —
       * the browser only ever speaks to localhost:5173, and Vite
       * transparently relays the request to Django.
       *
       * No changes are needed in production where the reverse proxy
       * (Nginx / Caddy) handles the same routing.
       */
      '/api': {
        target: 'http://127.0.0.1:8000',
        changeOrigin: true,
        secure: false,
      },
    },
  },
})
