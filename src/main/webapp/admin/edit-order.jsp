<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="./class/edit-order.jsp" %>


<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ແກ້ໄຂຄຳສັ່ງຊື້ - POS ສົ່ງອອກ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="./css/edit-order.css" rel="stylesheet">
    <link rel="icon" href="../logo/logo.png" type="image/png">

</head>
<body>
    <div class="container-fluid">
        <div class="row">

            <div class="col-md-2 sidebar p-0">
                <div class="p-4 text-center border-bottom border-white border-opacity-25">
                    <i class="bi bi-box-seam" style="font-size: 3rem;"></i>
                    <h5 class="mt-2">POS ສົ່ງອອກ</h5>
                    <small><%= session.getAttribute("fullName") %></small>
                </div>
                <nav class="mt-3">
                    <a href="dashboard.jsp">
                        <i class="bi bi-speedometer2"></i> ໜ້າຫຼັກ
                    </a>
                    <a href="products.jsp">
                        <i class="bi bi-box"></i> ຈັດການສິນຄ້າ
                    </a>
                    <a href="users.jsp">
                        <i class="bi bi-people"></i> ຈັດການພະນັກງານ
                    </a>
                    <a href="reports.jsp">
                        <i class="bi bi-file-earmark-text"></i> ລາຍງານ
                    </a>
                    <hr class="border-white border-opacity-25">
                    <a href="../logout.jsp" class="text-warning">
                        <i class="bi bi-box-arrow-right"></i> Logout
                    </a>
                </nav>
            </div>

       
            <div class="col-md-10 p-4">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2><i class="bi bi-pencil-square"></i> ແກ້ໄຂຄຳສັ່ງຊື້</h2>
                    <div class="text-end">
                        <small class="text-muted">
                            <i class="bi bi-calendar"></i> <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %>
                        </small>
                    </div>
                </div>

                <% if ("1".equals(request.getParameter("success"))) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i>
                    <strong>ສຳເລັດ!</strong> ບັນທຶກການແກ້ໄຂຄຳສັ່ງຊື້ແລ້ວ
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% } else if ("1".equals(request.getParameter("error"))) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>
                    <strong>ເກີດຂໍ້ຜິດພາດ!</strong> ບໍ່ສາມາດບັນທຶກການແກ້ໄຂໄດ້
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% } %>

          
                <div class="edit-form">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <h5><strong>ເລກທີ່ສັ່ງຊື້:</strong> <%= orderHeader.get("export_code") %></h5>
                            <p><strong>ວັນທີ:</strong> <%= dateFormat.format(orderHeader.get("export_date")) %></p>
                            <p><strong>ຜູ້ບັນທຶກ:</strong> <%= orderHeader.get("user_name") %></p>
                        </div>
                        <div class="col-md-6 text-end">
                            <h4 class="text-success">ລວມທັງໝົດ: <%= df.format(orderHeader.get("total_amount")) %> ກີບ</h4>
                            <p class="mb-0"><%= orderHeader.get("item_count") %> ລາຍການ</p>
                        </div>
                    </div>
                </div>


                <form method="post" action="update-order.jsp" class="edit-form">
                    <input type="hidden" name="export_code" value="<%= exportCode %>">

                    <h5 class="mb-3"><i class="bi bi-list-check"></i> ແກ້ໄຂລາຍການສິນຄ້າ</h5>
                    

                    <div class="table-responsive">
                        <table class="table table-striped">
                            <thead class="table-dark">
                                <tr>
                                    <th>ລະຫັດສິນຄ້າ</th>
                                    <th>ຊື່ສິນຄ້າ</th>
                                    <th class="text-center">ຈຳນວນ</th>
                                    <th class="text-end">ລາຄາຕໍ່ໜ່ວຍ</th>
                                    <th class="text-end">ລວມ</th>
                                    <th class="text-center">ການປະຕິບັດ</th>
                                </tr>
                            </thead>
                            <tbody>
                              <% for (Map<String, Object> item : orderItems) { %>
                                <tr>
                                    <td><%= item.get("product_code") %></td>
                                    <td><%= item.get("product_name") %></td>
                                    <td class="text-center">
                                        <input type="number" name="quantity_<%= item.get("id") %>"
                                               value="<%= item.get("quantity") %>"
                                               min="0" max="<%= ((Integer)item.get("stock")) + ((Integer)item.get("quantity")) %>"
                                               class="form-control quantity-input d-inline-block">
                                    </td>
                                    <td class="text-end"><%= df.format(item.get("unit_price")) %> ກີບ</td>
                                    <td class="text-end" id="total_<%= item.get("id") %>"><%= df.format(item.get("total_price")) %> ກີບ</td>
                                    <td class="text-center">
                                        <button type="button" class="btn btn-outline-danger btn-sm"
                                                onclick="removeItem(<%= item.get("id") %>)">
                                            <i class="bi bi-trash"></i> ລຶບ
                                        </button>
                                    </td>
                                </tr>
                                <% } %>

                            </tbody>
                        </table>
                    </div>

                    <div class="row mt-4">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="notes" class="form-label">ເບີໂທຜູ້ສັ່ງ</label>
                                <textarea class="form-control" id="notes" name="notes" rows="3"
                                          placeholder="ເບີໂທຜູ້ສັ່ງ"><%= orderHeader.get("notes") != null ? orderHeader.get("notes") : "" %></textarea>
                            </div>
                        </div>
                        <div class="col-md-6 text-end">
                            <div class="mb-3">
                                <strong>ລວມທັງໝົດໃໝ່: <span id="grand_total" class="text-success h5"><%= df.format(orderHeader.get("total_amount")) %> ກີບ</span></strong>
                            </div>
                            <button type="submit" class="btn btn-primary me-2">
                                <i class="bi bi-check-circle"></i> ບັນທຶກການແກ້ໄຂ
                            </button>
                            <a href="dashboard.jsp" class="btn btn-secondary">
                                <i class="bi bi-x-circle"></i> ຍົກເລີກ
                            </a>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>

        document.querySelectorAll('input[type="number"]').forEach(input => {
            input.addEventListener('input', function() {
                updateTotals();
            });
        });

        function updateTotals() {
            let grandTotal = 0;

            <% for (Map<String, Object> item : orderItems) { %>
                const qty_<%= item.get("id") %> = document.querySelector('input[name="quantity_<%= item.get("id") %>"]').value;
                const unitPrice_<%= item.get("id") %> = <%= item.get("unit_price") %>;
                const total_<%= item.get("id") %> = qty_<%= item.get("id") %> * unitPrice_<%= item.get("id") %>;
                document.getElementById('total_<%= item.get("id") %>').textContent = '' + total_<%= item.get("id") %>.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
                grandTotal += total_<%= item.get("id") %>;
            <% } %>

            document.getElementById('grand_total').textContent = '' + grandTotal.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        }

        function removeItem(itemId) {
            if (confirm('ທ່ານແນ່ໃຈວ່າຕ້ອງການລຶບລາຍການນີ້ອອກຈາກຄຳສັ່ງຊື້?')) {
                const form = document.createElement('form');
                form.method = 'post';
                form.action = 'update-order.jsp';

                const exportCodeInput = document.createElement('input');
                exportCodeInput.type = 'hidden';
                exportCodeInput.name = 'export_code';
                exportCodeInput.value = '<%= exportCode %>';
                form.appendChild(exportCodeInput);

                const removeInput = document.createElement('input');
                removeInput.type = 'hidden';
                removeInput.name = 'remove_item';
                removeInput.value = itemId;
                form.appendChild(removeInput);

                document.body.appendChild(form);
                form.submit();
            }
        }
    </script>
</body>
</html>
