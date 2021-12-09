import { defineConfig } from 'vite'
import elmPlugin from 'vite-plugin-elm'

export default defineConfig({
    plugins: [elmPlugin()],
    json: {
        // https://vitejs.dev/config/#json-stringify
        // this is faster, pus we do not need to destructure the JSON anyway
        stringify: true
    }
})