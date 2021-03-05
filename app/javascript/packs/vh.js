
const vh = () => {
    let stabiloHeigtht = window.innerHeight * 0.01;
    document.documentElement.style.setProperty('--vh', `${stabiloHeigtht}px`)
}

const vhOnResize = () => {
    window.addEventListener('resize', () => {
    let stabiloHeigtht = window.innerHeight * 0.01;
    document.documentElement.style.setProperty('--vh', `${stabiloHeigtht}px`);
})
};

export {vh, vhOnResize};