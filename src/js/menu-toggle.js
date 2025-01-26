// Get references to the menu and toggle button
const menu = document.getElementById('layout-menu');
const toggleButton = document.getElementById('menu-toggle');
const body = document.body;

// Function to check mobile view and set initial state
function initializeMenuState() {
    const isMobile = window.matchMedia('(max-width: 1000px)').matches;
    
    if (isMobile) {
        menu.classList.remove('active');
        body.classList.remove('menu-open');
    } else {
        menu.classList.add('active');
        body.classList.remove('menu-open');
    }
}

// Initialize menu state on page load
initializeMenuState();

// Add click event listener to toggle button
toggleButton.addEventListener('click', () => {
    const isMobile = window.matchMedia('(max-width: 1000px)').matches;
    
    if (isMobile) {
        menu.classList.toggle('active');
        body.classList.toggle('menu-open');
    }
});

// Update menu state when window is resized
window.addEventListener('resize', initializeMenuState);