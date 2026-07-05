import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import fs from 'node:fs'
import path from 'node:path'

// Local HTTPS dev cert (mkcert), generated to cover localhost, the LAN IP,
// and its .nip.io hostname. Browsers only expose getUserMedia() (voice
// recording) in a "secure context" — localhost is exempted from that rule,
// but a LAN IP over plain HTTP is NOT, so cross-device/mobile testing needs
// real HTTPS here. Falls back to plain HTTP if the cert hasn't been
// generated yet (see docs on running `mkcert` locally), so a fresh clone
// without certs still starts up fine.
const certDir = path.resolve(__dirname, '.certs')
const keyPath = path.join(certDir, 'key.pem')
const certPath = path.join(certDir, 'cert.pem')
const httpsConfig =
  fs.existsSync(keyPath) && fs.existsSync(certPath)
    ? { key: fs.readFileSync(keyPath), cert: fs.readFileSync(certPath) }
    : undefined

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    https: httpsConfig,
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
