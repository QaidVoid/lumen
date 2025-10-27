/**
 * @type {import("phoenix_live_view").Hook}
 */
const Clipboard = {
  mounted() {
    this.handleEvent("copy-to-clipboard", ({ text, button_id }) => {
      if (this.el.id === button_id) {
        navigator.clipboard.writeText(text).then(() => {
          const originalHTML = this.el.innerHTML;
          this.el.innerHTML =
            '<svg class="size-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>';

          setTimeout(() => {
            this.el.innerHTML = originalHTML;
          }, 2000);
        });
      }
    });
  },
};

export default Clipboard;
