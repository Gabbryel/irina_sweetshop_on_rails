
export default function renderModal() {
  if (document.getElementById('modal-2021-overlay')) {
    const modal = document.getElementById('modal-2021-overlay');
    const closeModal = document.getElementById('close-easter-modal');
    closeModal.addEventListener('click', () => {
      modal.style.display = 'none';
    })
    setTimeout(() => {
      modal.style.display = 'none';
    },20000)
  }
}



