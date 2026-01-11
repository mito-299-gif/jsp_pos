function resetForm() {
  document.getElementById("userForm").reset();
  document.getElementById("action").value = "add";
  document.getElementById("userId").value = "";
  document.getElementById("password").required = true;
  document.getElementById("passwordLabel").textContent = "*";
  document.getElementById("passwordHint").style.display = "none";
  document.getElementById("modalTitle").innerHTML =
    '<i class="bi bi-plus-circle"></i> ເພີ່ມພະນັກງານໃໝ່';
}

function editUser(id, username, fullName, role) {
  document.getElementById("action").value = "edit";
  document.getElementById("userId").value = id;
  document.getElementById("username").value = username;
  document.getElementById("fullName").value = fullName;
  document.getElementById("role").value = role;
  document.getElementById("password").value = "";
  document.getElementById("password").required = false;
  document.getElementById("passwordLabel").textContent = "";
  document.getElementById("passwordHint").style.display = "block";
  document.getElementById("modalTitle").innerHTML =
    '<i class="bi bi-pencil"></i> ແກ້ໄຂຂໍ້ມູນພະນັກງານ';

  var modal = new bootstrap.Modal(document.getElementById("userModal"));
  modal.show();
}
