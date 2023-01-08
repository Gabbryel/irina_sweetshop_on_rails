export default function renderDisclaimerModal() {
  if (document.getElementById('disclaimerModal')) {
    const disclaimerModal = document.getElementById('disclaimerModal');
    const closeDisclaimerModal = document.getElementById('btn-close-disclaimer');
    window.onload = (e) => {
      if(sessionStorage.getItem('disclaimer')) {
        null
      } else {
          disclaimerModal.style.display = 'block';
          disclaimerModal.style.opacity = '1';
          sessionStorage.setItem('disclaimer', '1')
        }
      }
      closeDisclaimerModal.addEventListener('click', () => {
        disclaimerModal.style.display = 'none';
        disclaimerModal.style.opacity = '0';
      })
    }
  }
