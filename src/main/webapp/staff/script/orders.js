function viewOrderDetails(exportCode) {
  fetch("order-details-fixed.jsp?export_code=" + encodeURIComponent(exportCode))
    .then((response) => response.text())
    .then((html) => {
      document.getElementById("orderDetailsContent").innerHTML = html;
      new bootstrap.Modal(document.getElementById("orderDetailsModal")).show();
    })
    .catch((error) => {
      console.error("Error loading order details:", error);
      alert("ເກີດຂໍ້ຜິດພາດໃນການໂຫຼດຂໍ້ມູນ");
    });
}

function printOrder() {
  try {
    const orderDetails = document.querySelector(".order-details");
    if (!orderDetails) {
      console.error("Order details not found");
      alert("ບໍ່ພົບຂໍ້ມູນສຳລັບພິມພິ້ນ");
      return;
    }

    const originalContent = document.body.innerHTML;

    const printHeader =
      '<div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #333; padding-bottom: 10px; margin-bottom: 20px;">' +
      '<h2 style="margin: 0; color: #333;">ໃບສັ່ງຊື້ສິນຄ້າ</h2>' +
      '<p style="margin: 5px 0;">Export Order Receipt</p>' +
      "</div>";

    const orderContent = orderDetails.outerHTML
      .replace(/max-height: 70vh/g, "max-height: none")
      .replace(/overflow-y: auto/g, "overflow: visible");

    document.body.innerHTML =
      '<div style="font-family: Arial, sans-serif; margin: 20px;">' +
      printHeader +
      '<div style="margin-top: 20px;">' +
      orderContent +
      "</div>" +
      '<div style="text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; color: #666;">' +
      "ພິມພິ້ນ: " +
      new Date().toLocaleString("th-TH") +
      "</div>" +
      "</div>";

    const printBtn = document.querySelector(".text-center button");
    if (printBtn) {
      printBtn.style.display = "none";
    }

    const style = document.createElement("style");
    style.textContent = `
                    @media print {
                        body { margin: 0; font-size: 12px; }
                        .order-details { max-height: none !important; overflow: visible !important; }
                        table { font-size: 11px; width: 100%; }
                        button { display: none !important; }
                    }
                `;
    document.head.appendChild(style);

    window.print();

    setTimeout(function () {
      document.body.innerHTML = originalContent;
    }, 1000);
  } catch (error) {
    console.error("Print error:", error);
    alert("ເກີດຂໍ້ຜິດພາດໃນການພິມພິ້ນ: " + error.message);
  }
}

function filterByUser(userId) {
  if (userId) {
    window.location.href = "?filter=others&user=" + userId;
  } else {
    window.location.href = "?filter=others";
  }
}

document.getElementById("searchOrder").addEventListener("input", function (e) {
  const search = e.target.value.toLowerCase();
  document.querySelectorAll(".order-card").forEach((card) => {
    const orderCode = card
      .querySelector(".order-header h5")
      .textContent.toLowerCase();
    if (orderCode.includes(search)) {
      card.style.display = "block";
    } else {
      card.style.display = "none";
    }
  });
});
