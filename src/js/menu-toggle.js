(() => {
    const menu = document.getElementById("layout-menu");
    const toggleButton = document.getElementById("menu-toggle");
    const backdrop = document.getElementById("menu-backdrop");
    const mobileViewport = window.matchMedia("(max-width: 54rem)");

    if (!menu || !toggleButton) {
        return;
    }

    const setMenuOpen = (open, returnFocus = false) => {
        const shouldOpen = mobileViewport.matches && open;
        menu.classList.toggle("mobile-visible", shouldOpen);
        document.body.classList.toggle("menu-open", shouldOpen);
        toggleButton.setAttribute("aria-expanded", String(shouldOpen));
        toggleButton.setAttribute(
            "aria-label",
            shouldOpen ? "Close navigation" : "Open navigation"
        );
        menu.setAttribute(
            "aria-hidden",
            String(mobileViewport.matches && !shouldOpen)
        );

        if (!shouldOpen && returnFocus) {
            toggleButton.focus();
        }
    };

    const syncViewport = () => {
        setMenuOpen(false);
        if (!mobileViewport.matches) {
            menu.removeAttribute("aria-hidden");
        }
    };

    toggleButton.addEventListener("click", () => {
        setMenuOpen(!menu.classList.contains("mobile-visible"));
    });

    if (backdrop) {
        backdrop.addEventListener("click", () => setMenuOpen(false, true));
    }

    menu.addEventListener("click", (event) => {
        if (event.target.closest("a") && mobileViewport.matches) {
            setMenuOpen(false);
        }
    });

    document.addEventListener("keydown", (event) => {
        if (event.key === "Escape" && menu.classList.contains("mobile-visible")) {
            setMenuOpen(false, true);
        }
    });

    if (typeof mobileViewport.addEventListener === "function") {
        mobileViewport.addEventListener("change", syncViewport);
    } else {
        mobileViewport.addListener(syncViewport);
    }

    syncViewport();
})();
