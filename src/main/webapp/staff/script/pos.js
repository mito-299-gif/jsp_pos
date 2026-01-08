let cart = [];

function selectProduct(id, name, price, maxStock) {
  const existing = cart.find((item) => item.id === id);

  if (existing) {
    if (existing.quantity >= maxStock) {
      alert(`ບໍ່ສາມາດເພີ່ມໄດ້ ມີສະຕ໋ອກເທິງ ${maxStock} ຊິ້ນ`);
      return;
    }
    existing.quantity += 1;
  } else {
    cart.push({ id, name, price, quantity: 1, maxStock });
  }

  updateCart();
}

function updateQuantity(id, change) {
  const item = cart.find((i) => i.id === id);
  if (item) {
    const newQty = item.quantity + change;

    if (newQty > item.maxStock) {
      alert(`ບໍ່ສາມາດເພີ່ມໄດ້ ມີສະຕ໋ອກເທິງ ${item.maxStock} ຊິ້ນ`);
      return;
    }

    if (newQty <= 0) {
      removeItem(id);
    } else {
      item.quantity = newQty;
    }
    updateCart();
  }
}

function updateQuantityInput(id, value) {
  const item = cart.find((i) => i.id === id);
  if (item) {
    const qty = parseInt(value);
    if (isNaN(qty) || qty <= 0) {
      removeItem(id);
    } else if (qty > item.maxStock) {
      alert(`ບໍ່ສາມາດເພີ່ມໄດ້ ມີສະຕ໋ອກເທິງ ${item.maxStock} ຊິ້ນ`);
      item.quantity = item.maxStock;
    } else {
      item.quantity = qty;
    }
    updateCart();
  }
}

function removeItem(id) {
  cart = cart.filter((i) => i.id !== id);
  updateCart();
}

function updateCart() {
  const container = document.getElementById("cartItems");
  const submitBtn = document.getElementById("submitBtn");

  if (cart.length === 0) {
    container.innerHTML = `
                    <p class="text-center text-muted">
                        <i class="bi bi-cart-x" style="font-size: 3rem;"></i><br>
                        ຍັງບໍ່ມີສິນຄ້າໃນລາຍການ
                    </p>
                `;
    submitBtn.disabled = true;
    document.getElementById("totalAmount").textContent = "0 ກີບ";
    return;
  }

  let html = "";
  let total = 0;

  cart.forEach((item) => {
    const subtotal = item.price * item.quantity;
    total += subtotal;

    html +=
      '<div class="cart-item">' +
      '<input type="hidden" name="productId[]" value="' +
      item.id +
      '">' +
      '<div class="d-flex justify-content-between align-items-start mb-2">' +
      "<div>" +
      "<strong>" +
      item.name +
      "</strong><br>" +
      '<small class="text-muted">' +
      item.price.toFixed(0).replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,") +
      " ກີບ | ສະຕ໋ອກ: " +
      item.maxStock +
      " ຊິ້ນ</small>" +
      "</div>" +
      '<button type="button" class="btn btn-sm btn-danger" onclick="removeItem(' +
      item.id +
      ')">' +
      '<i class="bi bi-trash"></i>' +
      "</button>" +
      "</div>" +
      '<div class="d-flex justify-content-between align-items-center">' +
      '<div class="d-flex align-items-center">' +
      '<button type="button" class="btn btn-outline-secondary btn-sm" onclick="updateQuantity(' +
      item.id +
      ', -1)">-</button>' +
      '<input type="number" class="form-control form-control-sm text-center mx-1" style="width: 60px;" name="quantity[]" value="' +
      item.quantity +
      '" min="1" max="' +
      item.maxStock +
      '" onchange="updateQuantityInput(' +
      item.id +
      ', this.value)">' +
      '<button type="button" class="btn btn-outline-secondary btn-sm" onclick="updateQuantity(' +
      item.id +
      ', 1)">+</button>' +
      "</div>" +
      '<strong class="text-success">' +
      subtotal.toFixed(0).replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,") +
      " ກີບ</strong>" +
      "</div>" +
      "</div>";
  });

  container.innerHTML = html;
  document.getElementById("totalAmount").textContent =
    total.toFixed(0).replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,") + " ກີບ";
  submitBtn.disabled = false;
}

function clearCart() {
  if (confirm("ຢືນຢັນການລ້າງລາຍການທັງໝົດ?")) {
    cart = [];
    updateCart();
  }
}

document
  .getElementById("searchProduct")
  .addEventListener("input", function (e) {
    const search = e.target.value.toLowerCase();
    document.querySelectorAll(".product-item").forEach((item) => {
      const name = item.dataset.name;
      const code = item.dataset.code;
      if (name.includes(search) || code.includes(search)) {
        item.style.display = "block";
      } else {
        item.style.display = "none";
      }
    });
  });
