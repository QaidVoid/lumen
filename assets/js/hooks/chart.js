/**
 * @type {import("phoenix_live_view").Hook}
 */
const Chart = {
  mounted() {
    const ctx = this.el.getContext("2d");
    const config = JSON.parse(this.el.dataset.chart);

    this.chart = new window.Chart(ctx, config);

    this.handleEvent("update-chart", ({ data }) => {
      this.chart.data = data;
      this.chart.update();
    });
  },

  destroyed() {
    if (this.chart) {
      this.chart.destroy();
    }
  },
};

export default Chart;
