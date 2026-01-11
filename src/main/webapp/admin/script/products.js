function editProduct(id) {
  fetch("?action=get&id=" + id)
    .then((response) => response.json())
    .then((data) => {
      document.getElementById("editProductId").value = data.id;
      document.getElementById("editProductCode").value = data.product_code;
      document.getElementById("editProductName").value = data.product_name;
      document.getElementById("editCategory").value = data.category;
      document.getElementById("editCostPrice").value = data.cost_price;
      document.getElementById("editSellPrice").value = data.sell_price;
      document.getElementById("editStock").value = data.stock;
      document.getElementById("editMinStock").value = data.min_stock;
      new bootstrap.Modal(document.getElementById("editProductModal")).show();
    });
}
