// frontend/vite.config.js — proxy до API
export default {
  server: {
    host: "0.0.0.0", // Обов'язково для Docker!
    port: 3000,
    hmr: {
      port: 3000, // HMR через той самий порт
    },
    proxy: {
      "/api": {
        target: "http://backend:5000", // ім'я сервісу!
        changeOrigin: true,
      },
    },
  },
};
