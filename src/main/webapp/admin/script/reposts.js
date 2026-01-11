function exportExcel() {
  const params = new URLSearchParams(window.location.search);
  params.set("export", "excel");
  window.location.href = "reports.jsp?" + params.toString();
}
