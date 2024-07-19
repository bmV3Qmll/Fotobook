var dropArea = document.getElementsByClassName("drop-area")[0];
var imgUpload = document.getElementsByClassName("img-upload")[0];
var imgView = document.getElementsByClassName("img-view")[0];
var addBtn = document.getElementsByClassName("add_fields")[0];
var dataTransfer;

function replaceImage(fileView, image) {
  let imgLink = URL.createObjectURL(image);
  let imgElem = document.createElement('img');
  imgElem.src = imgLink;
  fileView.replaceChild(imgElem, fileView.children[0]);
}

function uploadImage(e) {
  let fileInput = e.target;
  let fileView = $(fileInput).siblings('.img-view')[0];
  let image = fileInput.files[0];
  if (!validateFileSize(image)) {
    return;
  }
  replaceImage(fileView, image)
}

function uploadImages() {
  for (const file of imgUpload.files) {
    if (!validateFileSize(file)) {
      continue;
    }

    dataTransfer = new DataTransfer();
    dataTransfer.items.add(file);
    addBtn.click();
  }

  imgUpload.files = new DataTransfer().files;
}

function validateFileSize(file) {
  let lim = imgUpload.id == "user_avatar" ? 2 : 5;
  if (file.size / 1024 / 1024 > lim) {
    alert(`File ${file.name} too Big, please select a file less than ${lim}Mb`);
    return false;
  }
  return true;
}

if (imgUpload.multiple) {
  imgUpload.addEventListener("change", uploadImages);
} else {
  imgUpload.addEventListener("change", uploadImage);
}

dropArea.addEventListener("dragover", e => {
  e.preventDefault();
});

dropArea.addEventListener("drop", e => {
  e.preventDefault();
  imgUpload.files = e.dataTransfer.files;
  if (imgUpload.multiple) {
    uploadImages();
  } else {
    imgUpload.dispatchEvent(new Event('change'));
  }
});

$(document).on('cocoon:after-insert', function(e, insertedItem) {
  let fileInput = $(insertedItem).find('.album-images-input')[0];
  fileInput.files = dataTransfer.files;
  replaceImage($(insertedItem).find('.img-view')[0], fileInput.files[0]);
  fileInput.addEventListener("change", uploadImage);
});