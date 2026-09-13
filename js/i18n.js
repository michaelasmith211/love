// ==========================================================================
// LOVE CALCULATOR - 40 LANGUAGES INTERNATIONALIZATION (i18n) ENGINE
// ==========================================================================

(function() {
  const LANGUAGES = [
    { code: 'en', name: 'English', native: 'English', flag: '🇺🇸', dir: 'ltr' },
    { code: 'es', name: 'Spanish', native: 'Español', flag: '🇪🇸', dir: 'ltr' },
    { code: 'fr', name: 'French', native: 'Français', flag: '🇫🇷', dir: 'ltr' },
    { code: 'de', name: 'German', native: 'Deutsch', flag: '🇩🇪', dir: 'ltr' },
    { code: 'pt', name: 'Portuguese', native: 'Português', flag: '🇧🇷', dir: 'ltr' },
    { code: 'it', name: 'Italian', native: 'Italiano', flag: '🇮🇹', dir: 'ltr' },
    { code: 'hi', name: 'Hindi', native: 'हिन्दी', flag: '🇮🇳', dir: 'ltr' },
    { code: 'ar', name: 'Arabic', native: 'العربية', flag: '🇸🇦', dir: 'rtl' },
    { code: 'ru', name: 'Russian', native: 'Русский', flag: '🇷🇺', dir: 'ltr' },
    { code: 'ja', name: 'Japanese', native: '日本語', flag: '🇯🇵', dir: 'ltr' },
    { code: 'zh', name: 'Chinese Simplified', native: '简体中文', flag: '🇨🇳', dir: 'ltr' },
    { code: 'zh-TW', name: 'Chinese Traditional', native: '繁體中文', flag: '🇹🇼', dir: 'ltr' },
    { code: 'ko', name: 'Korean', native: '한국어', flag: '🇰🇷', dir: 'ltr' },
    { code: 'tr', name: 'Turkish', native: 'Türkçe', flag: '🇹🇷', dir: 'ltr' },
    { code: 'nl', name: 'Dutch', native: 'Nederlands', flag: '🇳🇱', dir: 'ltr' },
    { code: 'pl', name: 'Polish', native: 'Polski', flag: '🇵🇱', dir: 'ltr' },
    { code: 'id', name: 'Indonesian', native: 'Bahasa Indonesia', flag: '🇮🇩', dir: 'ltr' },
    { code: 'vi', name: 'Vietnamese', native: 'Tiếng Việt', flag: '🇻🇳', dir: 'ltr' },
    { code: 'th', name: 'Thai', native: 'ไทย', flag: '🇹🇭', dir: 'ltr' },
    { code: 'uk', name: 'Ukrainian', native: 'Українська', flag: '🇺🇦', dir: 'ltr' },
    { code: 'ro', name: 'Romanian', native: 'Română', flag: '🇷🇴', dir: 'ltr' },
    { code: 'el', name: 'Greek', native: 'Ελληνικά', flag: '🇬🇷', dir: 'ltr' },
    { code: 'cs', name: 'Czech', native: 'Čeština', flag: '🇨🇿', dir: 'ltr' },
    { code: 'sv', name: 'Swedish', native: 'Svenska', flag: '🇸🇪', dir: 'ltr' },
    { code: 'hu', name: 'Hungarian', native: 'Magyar', flag: '🇭🇺', dir: 'ltr' },
    { code: 'bn', name: 'Bengali', native: 'বাংলা', flag: '🇧🇩', dir: 'ltr' },
    { code: 'tl', name: 'Filipino', native: 'Filipino', flag: '🇵🇭', dir: 'ltr' },
    { code: 'ms', name: 'Malay', native: 'Bahasa Melayu', flag: '🇲🇾', dir: 'ltr' },
    { code: 'he', name: 'Hebrew', native: 'עברית', flag: '🇮🇱', dir: 'rtl' },
    { code: 'da', name: 'Danish', native: 'Dansk', flag: '🇩🇰', dir: 'ltr' },
    { code: 'fi', name: 'Finnish', native: 'Suomi', flag: '🇫🇮', dir: 'ltr' },
    { code: 'no', name: 'Norwegian', native: 'Norsk', flag: '🇳🇴', dir: 'ltr' },
    { code: 'fa', name: 'Persian', native: 'فارسی', flag: '🇮🇷', dir: 'rtl' },
    { code: 'ur', name: 'Urdu', native: 'اردو', flag: '🇵🇰', dir: 'rtl' },
    { code: 'ta', name: 'Tamil', native: 'தமிழ்', flag: '🇮🇳', dir: 'ltr' },
    { code: 'te', name: 'Telugu', native: 'తెలుగు', flag: '🇮🇳', dir: 'ltr' },
    { code: 'mr', name: 'Marathi', native: 'मराठी', flag: '🇮🇳', dir: 'ltr' },
    { code: 'sw', name: 'Swahili', native: 'Kiswahili', flag: '🇰🇪', dir: 'ltr' },
    { code: 'sk', name: 'Slovak', native: 'Slovenčina', flag: '🇸🇰', dir: 'ltr' },
    { code: 'bg', name: 'Bulgarian', native: 'Български', flag: '🇧🇬', dir: 'ltr' }
  ];

  function detectCurrentLang() {
    const pathParts = window.location.pathname.split('/').filter(Boolean);
    if (pathParts.length > 0) {
      const match = LANGUAGES.find(l => l.code.toLowerCase() === pathParts[0].toLowerCase());
      if (match) return match.code;
    }
    return document.documentElement.lang || 'en';
  }

  function getLangTargetUrl(targetCode) {
    const origin = window.location.origin;
    const pathParts = window.location.pathname.split('/').filter(Boolean);
    
    // Check if currently inside a lang subdirectory
    const isLangSubdir = LANGUAGES.some(l => l.code.toLowerCase() === (pathParts[0] || '').toLowerCase());
    
    let pageName = '';
    if (isLangSubdir) {
      pageName = pathParts.slice(1).join('/');
    } else {
      pageName = pathParts.join('/');
    }

    if (targetCode === 'en') {
      return origin + '/' + (pageName ? pageName : '');
    } else {
      return origin + '/' + targetCode + '/';
    }
  }

  function initLanguageUI() {
    const currentCode = detectCurrentLang();
    const currentLang = LANGUAGES.find(l => l.code === currentCode) || LANGUAGES[0];

    // Update button text
    const langBtnText = document.querySelector('.lang-current-code');
    if (langBtnText) {
      langBtnText.textContent = currentLang.code.toUpperCase();
    }

    const modal = document.getElementById('lang-modal');
    const openBtn = document.getElementById('btn-lang-selector');
    const closeBtn = document.getElementById('close-lang-modal');
    const grid = document.getElementById('lang-grid-container');
    const searchInput = document.getElementById('lang-search-input');

    if (!modal || !openBtn) return;

    function renderLanguages(filter = '') {
      if (!grid) return;
      grid.innerHTML = '';
      const query = filter.toLowerCase().trim();

      const filtered = LANGUAGES.filter(l => 
        !query || 
        l.name.toLowerCase().includes(query) || 
        l.native.toLowerCase().includes(query) || 
        l.code.toLowerCase().includes(query)
      );

      filtered.forEach(l => {
        const a = document.createElement('a');
        a.className = 'lang-item-link' + (l.code === currentCode ? ' active' : '');
        a.href = getLangTargetUrl(l.code);
        a.innerHTML = `
          <span class="lang-item-flag" aria-hidden="true">${l.flag}</span>
          <span class="lang-item-names">
            <span class="lang-item-native">${l.native}</span>
            <span class="lang-item-english">${l.name}</span>
          </span>
        `;
        a.addEventListener('click', () => {
          try {
            localStorage.setItem('preferred_lang', l.code);
          } catch(e) {}
        });
        grid.appendChild(a);
      });
    }

    openBtn.addEventListener('click', () => {
      renderLanguages();
      modal.classList.remove('hidden');
      if (searchInput) {
        searchInput.value = '';
        setTimeout(() => searchInput.focus(), 50);
      }
    });

    if (closeBtn) {
      closeBtn.addEventListener('click', () => modal.classList.add('hidden'));
    }

    modal.addEventListener('click', (e) => {
      if (e.target === modal) modal.classList.add('hidden');
    });

    if (searchInput) {
      searchInput.addEventListener('input', (e) => {
        renderLanguages(e.target.value);
      });
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initLanguageUI);
  } else {
    initLanguageUI();
  }
})();
