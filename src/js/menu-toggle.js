// Get references to the menu and toggle button
const menu = document.getElementById('layout-menu');
const toggleButton = document.getElementById('menu-toggle');

// Function to check mobile view and set initial state
function initializeMenuState() {
    const isMobile = window.matchMedia('(max-width: 767px)').matches;
    
    // Set initial state based on viewport
    if (isMobile) {
        menu.classList.add('hidden'); // Hide menu by default on mobile
        menu.style.position = 'fixed';
        menu.style.top = '5rem';
        menu.style.left = '1rem';
        menu.style.zIndex = '1000';
    } else {
        menu.classList.remove('hidden'); // Show menu by default on desktop
        menu.style.position = ''; // Reset position for desktop
        menu.style.top = '';
        menu.style.left = '';
        menu.style.zIndex = '';
    }
}

// Initialize menu state on page load
initializeMenuState();

// Add click event listener to toggle button
toggleButton.addEventListener('click', () => {
    menu.classList.toggle('hidden');
    
    // For mobile view, ensure proper positioning when toggling
    if (window.matchMedia('(max-width: 767px)').matches) {
        menu.style.position = 'fixed';
        menu.style.top = '5rem';
        menu.style.left = '1rem';
        menu.style.zIndex = '1000';
    }
});

// Update menu state when window is resized
window.addEventListener('resize', initializeMenuState);