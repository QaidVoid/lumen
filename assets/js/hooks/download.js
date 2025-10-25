/**
 * @type {import("phoenix_live_view").Hook}
 */
const Download = {
  mounted() {
    this.handleEvent("download", ({ data, filename, mime_type }) => {
      const blob = new Blob([data], { type: mime_type });
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = filename;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);
    });
  },
};

export default Download;
