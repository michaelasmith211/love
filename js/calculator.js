/**
 * Core Love Calculator Compatibility Engines
 * 1. Deterministic Name Compatibility
 * 2. 12x12 Zodiac Astrological Matrix
 * 3. Birthday Life Path Numerology Match
 * 4. Classic FLAMES Game Simulator
 * 5. URL Query Parameter Sync & Deep Linking
 */

// ==========================================
// 1. ZODIAC COMPATIBILITY DATABASE
// ==========================================
const ZODIAC_DATA = {
  aries: { name: 'Aries', element: 'Fire', dates: 'Mar 21 - Apr 19', symbol: '♈' },
  taurus: { name: 'Taurus', element: 'Earth', dates: 'Apr 20 - May 20', symbol: '♉' },
  gemini: { name: 'Gemini', element: 'Air', dates: 'May 21 - Jun 20', symbol: '♊' },
  cancer: { name: 'Cancer', element: 'Water', dates: 'Jun 21 - Jul 22', symbol: '♋' },
  leo: { name: 'Leo', element: 'Fire', dates: 'Jul 23 - Aug 22', symbol: '♌' },
  virgo: { name: 'Virgo', element: 'Earth', dates: 'Aug 23 - Sep 22', symbol: '♍' },
  libra: { name: 'Libra', element: 'Air', dates: 'Sep 23 - Oct 22', symbol: '♎' },
  scorpio: { name: 'Scorpio', element: 'Water', dates: 'Oct 23 - Nov 21', symbol: '♏' },
  sagittarius: { name: 'Sagittarius', element: 'Fire', dates: 'Nov 22 - Dec 21', symbol: '♐' },
  capricorn: { name: 'Capricorn', element: 'Earth', dates: 'Dec 22 - Jan 19', symbol: '♑' },
  aquarius: { name: 'Aquarius', element: 'Air', dates: 'Jan 20 - Feb 18', symbol: '♒' },
  pisces: { name: 'Pisces', element: 'Water', dates: 'Feb 19 - Mar 20', symbol: '♓' }
};

// Element Synergies
const ELEMENT_COMPATIBILITY = {
  'Fire-Fire': { score: 92, title: 'Blazing Passion', desc: 'An exhilarating connection filled with spontaneous adventures, boundless ambition, and fierce loyalty.' },
  'Fire-Air': { score: 95, title: 'Dynamic Wind & Flame', desc: 'Air fuels Fire to burn brighter. You inspire each other mentally, intellectually, and creatively.' },
  'Fire-Earth': { score: 68, title: 'Grounding Warmth', desc: 'Earth provides stability to Fire’s untamed drive, though patience is needed to balance speed with caution.' },
  'Fire-Water': { score: 62, title: 'Steam & Intensity', desc: 'High emotional drama and magnetic attraction. Fire warms Water, while Water softens Fire’s edges.' },
  'Earth-Earth': { score: 90, title: 'Rock-Solid Devotion', desc: 'Unbreakable foundation built on mutual trust, shared work ethic, and practical sensuality.' },
  'Earth-Air': { score: 65, title: 'Mind & Matter', desc: 'Air brings intellectual whimsy while Earth builds tangible security. Thrives when both appreciate their differences.' },
  'Earth-Water': { score: 94, title: 'Nurturing Soil & Rain', desc: 'One of the most naturally harmonious pairings. Deep security, intuitive empathy, and lasting romantic devotion.' },
  'Air-Air': { score: 88, title: 'Endless Intellectual Spark', desc: 'Vibrant banter, social ease, and freedom. A telepathic friendship that blossoms into breezy romance.' },
  'Air-Water': { score: 64, title: 'Waves & Breezes', desc: 'Air rationalizes while Water feels deeply. Magical when emotional vulnerability bridges the communication gap.' },
  'Water-Water': { score: 93, title: 'Oceanic Soul Connection', desc: 'Psychic emotional attunement, intense intimacy, and deep spiritual understanding that transcends words.' }
};

// ==========================================
// 2. NAME COMPATIBILITY ALGORITHM
// ==========================================
function calculateNameLove(rawName1, rawName2) {
  const n1 = rawName1.trim().toLowerCase().replace(/[^\p{L}\p{N}]/gu, '');
  const n2 = rawName2.trim().toLowerCase().replace(/[^\p{L}\p{N}]/gu, '');

  if (!n1 || !n2) {
    return { error: 'Please enter both names to test compatibility.' };
  }

  // Canonical order to guarantee bidirectional symmetry: Romeo + Juliet == Juliet + Romeo
  const [first, second] = [n1, n2].sort();
  const combined = first + '&' + second;

  // Multi-factor deterministic hash
  let hashA = 5381;
  let hashB = 0;
  for (let i = 0; i < combined.length; i++) {
    const char = combined.charCodeAt(i);
    hashA = ((hashA << 5) + hashA) + char;
    hashB = (hashB * 31 + char) % 1000000007;
  }

  // Vowel harmony bonus
  const vowels = new Set(['a', 'e', 'i', 'o', 'u', 'y']);
  let v1 = 0, v2 = 0;
  for (const c of n1) if (vowels.has(c)) v1++;
  for (const c of n2) if (vowels.has(c)) v2++;
  const vowelBalance = Math.abs(v1 - v2);

  // Common letter resonance
  const set1 = new Set(n1.split(''));
  const set2 = new Set(n2.split(''));
  let shared = 0;
  for (const c of set1) if (set2.has(c)) shared++;

  // Compute percentage (clamped between 58% and 98% for positive & entertaining UX)
  const baseRange = 40; // 58 to 98
  const rawScore = (Math.abs(hashA ^ hashB) % baseRange);
  const sharedBonus = Math.min(6, shared * 2);
  const vowelDeduction = Math.min(4, vowelBalance);
  
  let percentage = 58 + rawScore + sharedBonus - vowelDeduction;
  percentage = Math.max(54, Math.min(99, percentage));

  // Sub-scores derived deterministically
  const passion = Math.max(50, Math.min(99, percentage + ((hashA % 15) - 7)));
  const communication = Math.max(50, Math.min(99, percentage + ((hashB % 17) - 8)));
  const trust = Math.max(52, Math.min(99, percentage + (((hashA + hashB) % 13) - 5)));
  const future = Math.max(50, Math.min(99, Math.round((percentage * 2 + trust) / 3)));

  // Tiers and advice
  let tier = '';
  let description = '';
  let advice = '';

  if (percentage >= 90) {
    tier = '✨ Cosmic Twin Flames ✨';
    description = 'An extraordinarily rare and electrifying connection! Your names vibrate at an almost identical emotional frequency. Natural chemistry and spiritual understanding flow effortlessly.';
    advice = 'Celebrate this divine synergy! Keep sharing your dreams openly and support each other’s personal growth.';
  } else if (percentage >= 80) {
    tier = '💖 Soulmate Potential 💖';
    description = 'Deep emotional resonance, shared values, and high romantic magnetism. You balance each other’s quirks beautifully and build a safe haven together.';
    advice = 'Invest in quality time and sweet spontaneous surprises. Your connection only gets stronger with every conversation.';
  } else if (percentage >= 70) {
    tier = '🌟 Sweet Harmony & Spark 🌟';
    description = 'Strong attraction with playful banter and great mutual respect. You have distinct personalities that create healthy, exciting contrast.';
    advice = 'Focus on active listening and learning each other’s love languages to turn this sweet spark into an unbreakable bond.';
  } else {
    tier = '🔥 Dynamic & Passionate Growth 🔥';
    description = 'An intriguing "opposites attract" chemistry! While your natural temperaments differ, the sexual and intellectual tension creates captivating excitement.';
    advice = 'Patience is your superpower. Embrace healthy communication and celebrate the different perspectives you bring to the table.';
  }

  return {
    percentage,
    tier,
    description,
    advice,
    subscores: [
      { label: 'Romance & Chemistry', score: passion },
      { label: 'Communication Synergy', score: communication },
      { label: 'Emotional Trust', score: trust },
      { label: 'Long-term Future', score: future }
    ]
  };
}

// ==========================================
// 3. ZODIAC COMPATIBILITY ENGINE
// ==========================================
function calculateZodiacLove(sign1Key, sign2Key) {
  const s1 = ZODIAC_DATA[sign1Key.toLowerCase()];
  const s2 = ZODIAC_DATA[sign2Key.toLowerCase()];

  if (!s1 || !s2) {
    return { error: 'Please select valid Zodiac signs.' };
  }

  // Look up element key
  const elements = [s1.element, s2.element].sort();
  const pairKey = `${elements[0]}-${elements[1]}`;
  const elementInsight = ELEMENT_COMPATIBILITY[pairKey] || { score: 78, title: 'Balanced Flow', desc: 'Complementary energies that thrive on empathy.' };

  // Adjust score slightly if signs are identical or opposite
  let finalScore = elementInsight.score;
  let customNote = '';

  if (sign1Key === sign2Key) {
    finalScore = Math.min(96, finalScore + 4);
    customNote = `Double ${s1.name} synergy! You understand each other’s instincts instantly like looking into a cosmic mirror.`;
  } else {
    customNote = `${s1.name} (${s1.element}) meets ${s2.name} (${s2.element}). ${elementInsight.desc}`;
  }

  return {
    percentage: finalScore,
    tier: elementInsight.title,
    description: customNote,
    advice: `Focus on balancing ${s1.name}'s natural strengths with ${s2.name}'s desires. Cultivate shared passions.`,
    subscores: [
      { label: 'Elemental Alignment', score: finalScore },
      { label: 'Emotional Rapport', score: Math.min(99, finalScore + 2) },
      { label: 'Intimacy & Romance', score: Math.max(55, finalScore - 3) },
      { label: 'Intellectual Synergy', score: Math.min(98, finalScore + 5) }
    ],
    sign1: s1,
    sign2: s2
  };
}

// ==========================================
// 4. BIRTHDAY NUMEROLOGY ENGINE
// ==========================================
function calculateLifePath(dateStr) {
  if (!dateStr) return null;
  // Sum all digits
  const digits = dateStr.replace(/[^0-9]/g, '').split('').map(Number);
  if (digits.length === 0) return null;

  let sum = digits.reduce((acc, d) => acc + d, 0);

  // Reduce to single digit or master number (11, 22, 33)
  while (sum > 9 && sum !== 11 && sum !== 22 && sum !== 33) {
    sum = sum.toString().split('').map(Number).reduce((a, b) => a + b, 0);
  }
  return sum;
}

const NUMEROLOGY_TRAITS = {
  1: { archetype: 'The Leader', vibe: 'Independent, ambitious, pioneering' },
  2: { archetype: 'The Peacemaker', vibe: 'Empathetic, diplomatic, gentle' },
  3: { archetype: 'The Creative', vibe: 'Expressive, joyful, romantic' },
  4: { archetype: 'The Builder', vibe: 'Loyal, stable, structured' },
  5: { archetype: 'The Adventurer', vibe: 'Bold, curious, adaptable' },
  6: { archetype: 'The Nurturer', vibe: 'Loving, protective, harmonious' },
  7: { archetype: 'The Seeker', vibe: 'Mystical, analytical, philosophical' },
  8: { archetype: 'The Achiever', vibe: 'Powerful, driven, goal-oriented' },
  9: { archetype: 'The Humanitarian', vibe: 'Compassionate, generous, wise' },
  11: { archetype: 'The Intuitive Master', vibe: 'Spiritual, illuminated, charismatic' },
  22: { archetype: 'The Master Architect', vibe: 'Visionary, world-builder, grounded' },
  33: { archetype: 'The Master Healer', vibe: 'Unconditional love, uplifting, radiant' }
};

function calculateBirthdayLove(dob1, dob2) {
  const lp1 = calculateLifePath(dob1);
  const lp2 = calculateLifePath(dob2);

  if (!lp1 || !lp2) {
    return { error: 'Please enter both valid dates of birth.' };
  }

  // Harmonic compatibility matrix
  const diff = Math.abs(lp1 - lp2);
  let score = 80;
  if (lp1 === lp2) score = 95;
  else if ([1, 2, 4].includes(diff)) score = 88;
  else if ([3, 5, 7].includes(diff)) score = 79;
  else score = 74;

  const t1 = NUMEROLOGY_TRAITS[lp1] || { archetype: 'The Mystic', vibe: 'Unique' };
  const t2 = NUMEROLOGY_TRAITS[lp2] || { archetype: 'The Mystic', vibe: 'Unique' };

  return {
    percentage: score,
    tier: `Life Path ${lp1} & Life Path ${lp2}`,
    description: `Life Path ${lp1} (${t1.archetype}: ${t1.vibe}) paired with Life Path ${lp2} (${t2.archetype}: ${t2.vibe}). A deeply meaningful vibrational journey.`,
    advice: 'Honor your different rhythms. Your life paths are designed to teach each other soul lessons.',
    subscores: [
      { label: 'Vibrational Harmony', score: score },
      { label: 'Spiritual Resonance', score: Math.min(98, score + 4) },
      { label: 'Shared Life Vision', score: Math.max(50, score - 5) },
      { label: 'Daily Rhythm Sync', score: Math.min(95, score + 1) }
    ],
    lp1,
    lp2
  };
}

// ==========================================
// 5. CLASSIC FLAMES GAME ENGINE
// ==========================================
function calculateFLAMES(name1, name2) {
  let s1 = name1.toLowerCase().replace(/[^\p{L}\p{N}]/gu, '').split('');
  let s2 = name2.toLowerCase().replace(/[^\p{L}\p{N}]/gu, '').split('');

  if (s1.length === 0 || s2.length === 0) {
    return { error: 'Please enter both names for the FLAMES test.' };
  }

  // Cross strike letters
  let count1 = [...s1];
  let count2 = [...s2];

  for (let i = 0; i < count1.length; i++) {
    const char = count1[i];
    const matchIdx = count2.indexOf(char);
    if (matchIdx !== -1) {
      count1[i] = null;
      count2[matchIdx] = null;
    }
  }

  const remaining = count1.filter(Boolean).length + count2.filter(Boolean).length;
  const count = remaining === 0 ? 1 : remaining;

  // FLAMES sequence
  let flames = [
    { letter: 'F', meaning: 'Friends', desc: 'An unshakeable bond of trust, laughs, and lifelong camaraderie.', score: 82, emoji: '🤝' },
    { letter: 'L', meaning: 'Lovers', desc: 'Passionate romance, deep chemistry, and butterflies in your stomach!', score: 96, emoji: '❤️' },
    { letter: 'A', meaning: 'Affection', desc: 'Tender fondness, sweet care, warmth, and gentle daily devotion.', score: 88, emoji: '🥰' },
    { letter: 'M', meaning: 'Marriage', desc: 'Destined for eternal commitment, wedding bells, and building a home together.', score: 98, emoji: '💍' },
    { letter: 'E', meaning: 'Enemies', desc: 'Fierce rivals turned passionate sparks! High drama and fiery intensity.', score: 65, emoji: '⚡' },
    { letter: 'S', meaning: 'Siblings', desc: 'Protective, teasing comfort. You feel like family and watch each other’s back.', score: 75, emoji: '🫂' }
  ];

  let list = [...flames];
  let idx = 0;
  while (list.length > 1) {
    idx = (idx + count - 1) % list.length;
    list.splice(idx, 1);
  }

  const result = list[0];

  return {
    percentage: result.score,
    tier: `${result.emoji} FLAMES Result: ${result.meaning} ${result.emoji}`,
    description: `With ${count} remaining letters, your destiny landed on "${result.letter}" for ${result.meaning}. ${result.desc}`,
    advice: `Celebrate your ${result.meaning} energy! Whether as sweet lovers, loyal soul friends, or marriage partners, enjoy your bond.`,
    subscores: [
      { label: 'Affection Index', score: result.score },
      { label: 'Playful Chemistry', score: Math.min(99, result.score + 3) },
      { label: 'Emotional Closeness', score: Math.max(50, result.score - 4) },
      { label: 'Destiny Factor', score: result.score }
    ],
    flamesLetter: result.letter,
    flamesMeaning: result.meaning,
    remainingLetters: count
  };
}

// ==========================================
// 6. UI CONTROLLER & EVENT LISTENERS
// ==========================================
document.addEventListener('DOMContentLoaded', () => {
  // Tabs Navigation
  const tabBtns = document.querySelectorAll('.tab-btn');
  const tabPanes = document.querySelectorAll('.tab-pane');
  const resultCard = document.getElementById('result-section');

  tabBtns.forEach((btn) => {
    btn.addEventListener('click', () => {
      tabBtns.forEach((b) => b.classList.remove('active'));
      tabPanes.forEach((p) => p.classList.remove('active'));

      btn.classList.add('active');
      const targetPane = document.getElementById(btn.dataset.tab);
      if (targetPane) targetPane.classList.add('active');

      if (window.soundEngine) window.soundEngine.playClick();
    });
  });

  // Sound Toggle Button
  const soundBtn = document.getElementById('sound-toggle-btn');
  if (soundBtn) {
    const updateSoundIcon = () => {
      soundBtn.innerHTML = window.soundEngine && window.soundEngine.enabled
        ? '🔊 <span class="sr-only">Sound On</span>'
        : '🔇 <span class="sr-only">Sound Off</span>';
      soundBtn.setAttribute('aria-pressed', window.soundEngine.enabled);
    };
    updateSoundIcon();

    soundBtn.addEventListener('click', () => {
      if (window.soundEngine) {
        window.soundEngine.toggle();
        updateSoundIcon();
      }
    });
  }

  // Name Calculator Submission
  const nameForm = document.getElementById('name-calc-form');
  if (nameForm) {
    nameForm.addEventListener('submit', (e) => {
      e.preventDefault();
      const n1 = document.getElementById('calc-name1').value;
      const n2 = document.getElementById('calc-name2').value;

      runCalculation(() => calculateNameLove(n1, n2), {
        name1: n1,
        name2: n2,
        type: 'names'
      });
    });
  }

  // Zodiac Calculator Submission
  const zodiacForm = document.getElementById('zodiac-calc-form');
  if (zodiacForm) {
    zodiacForm.addEventListener('submit', (e) => {
      e.preventDefault();
      const s1 = document.getElementById('zodiac-sign1').value;
      const s2 = document.getElementById('zodiac-sign2').value;
      const s1Name = ZODIAC_DATA[s1]?.name || s1;
      const s2Name = ZODIAC_DATA[s2]?.name || s2;

      runCalculation(() => calculateZodiacLove(s1, s2), {
        name1: s1Name,
        name2: s2Name,
        type: 'zodiac'
      });
    });
  }

  // Birthday Calculator Submission
  const bdayForm = document.getElementById('bday-calc-form');
  if (bdayForm) {
    bdayForm.addEventListener('submit', (e) => {
      e.preventDefault();
      const b1 = document.getElementById('bday-date1').value;
      const b2 = document.getElementById('bday-date2').value;

      runCalculation(() => calculateBirthdayLove(b1, b2), {
        name1: `Person 1 (${b1})`,
        name2: `Person 2 (${b2})`,
        type: 'birthday'
      });
    });
  }

  // FLAMES Calculator Submission
  const flamesForm = document.getElementById('flames-calc-form');
  if (flamesForm) {
    flamesForm.addEventListener('submit', (e) => {
      e.preventDefault();
      const fn1 = document.getElementById('flames-name1').value;
      const fn2 = document.getElementById('flames-name2').value;

      runCalculation(() => calculateFLAMES(fn1, fn2), {
        name1: fn1,
        name2: fn2,
        type: 'flames'
      });
    });
  }

  // Calculation Orchestration with Heartbeat & Animation
  let currentResultData = null;

  function runCalculation(calcFn, meta) {
    const errorEl = document.getElementById('calc-error');
    if (errorEl) errorEl.textContent = '';

    const calcResult = calcFn();
    if (calcResult.error) {
      if (errorEl) errorEl.textContent = calcResult.error;
      return;
    }

    // Play heartbeat audio during calculation
    if (window.soundEngine) {
      window.soundEngine.playHeartbeat();
    }

    // GA4 Custom Event Tracking
    if (typeof window.gtag === 'function') {
      window.gtag('event', 'calculate_compatibility', {
        calculation_type: meta.type || 'unknown',
        event_category: 'engagement'
      });
    }

    // Smooth scroll down to result
    resultCard.classList.remove('hidden');
    resultCard.scrollIntoView({ behavior: 'smooth', block: 'start' });

    // Render loading state briefly for high anticipation
    animateResultScore(calcResult, meta);
  }

  function animateResultScore(result, meta) {
    const scoreNum = document.getElementById('result-score-number');
    const scoreCircle = document.getElementById('result-circle-progress');
    const tierTitle = document.getElementById('result-tier-title');
    const coupleNames = document.getElementById('result-couple-names');
    const description = document.getElementById('result-description');
    const advice = document.getElementById('result-advice');
    const subscoresContainer = document.getElementById('result-subscores');

    currentResultData = {
      name1: meta.name1,
      name2: meta.name2,
      percentage: result.percentage,
      tier: result.tier,
      subscores: result.subscores,
      type: meta.type
    };

    // Update Text Content
    coupleNames.textContent = `${meta.name1} & ${meta.name2}`;
    tierTitle.textContent = result.tier;
    description.textContent = result.description;
    advice.textContent = result.advice;

    // Render Subscore Bars
    subscoresContainer.innerHTML = '';
    result.subscores.forEach((s) => {
      const item = document.createElement('div');
      item.className = 'subscore-row';
      item.innerHTML = `
        <div class="subscore-info">
          <span>${s.label}</span>
          <span class="subscore-val">${s.score}%</span>
        </div>
        <div class="subscore-bar">
          <div class="subscore-fill" style="width: 0%" data-target="${s.score}%"></div>
        </div>
      `;
      subscoresContainer.appendChild(item);
    });

    // Animate Number Counter
    let count = 0;
    const target = result.percentage;
    const duration = 1200;
    const stepTime = 20;
    const steps = duration / stepTime;
    const increment = target / steps;

    const timer = setInterval(() => {
      count += increment;
      if (count >= target) {
        count = target;
        clearInterval(timer);
        if (window.soundEngine) window.soundEngine.playChime();
      }
      scoreNum.textContent = Math.round(count);

      // Circle SVG stroke-dashoffset: Circumference of r=70 is ~440
      const circumference = 440;
      const offset = circumference - (circumference * (count / 100));
      scoreCircle.style.strokeDashoffset = offset;
    }, stepTime);

    // Animate Subscore Progress Bars
    setTimeout(() => {
      document.querySelectorAll('.subscore-fill').forEach((bar) => {
        bar.style.width = bar.dataset.target;
      });
    }, 200);

    // Update URL hash/query without reload for easy sharing
    const newUrl = new URL(window.location);
    newUrl.searchParams.set('n1', encodeURIComponent(meta.name1));
    newUrl.searchParams.set('n2', encodeURIComponent(meta.name2));
    newUrl.searchParams.set('tab', meta.type);
    window.history.replaceState({}, '', newUrl);
  }

  // Share & Download Button Handlers
  const downloadCardBtn = document.getElementById('btn-download-card');
  if (downloadCardBtn) {
    downloadCardBtn.addEventListener('click', async () => {
      if (!currentResultData) return;
      downloadCardBtn.disabled = true;
      downloadCardBtn.textContent = 'Generating Image...';
      try {
        await window.loveCardEngine.downloadOrShare(currentResultData);
      } finally {
        downloadCardBtn.disabled = false;
        downloadCardBtn.innerHTML = '📥 Download Love Card';
      }
    });
  }

  // Copy Link Button
  const copyLinkBtn = document.getElementById('btn-copy-link');
  if (copyLinkBtn) {
    copyLinkBtn.addEventListener('click', () => {
      navigator.clipboard.writeText(window.location.href).then(() => {
        const orig = copyLinkBtn.innerHTML;
        copyLinkBtn.innerHTML = '✅ Link Copied!';
        setTimeout(() => {
          copyLinkBtn.innerHTML = orig;
        }, 2500);
      });
    });
  }

  // Embed Widget Modal Logic
  const embedBtn = document.getElementById('btn-get-embed');
  const embedModal = document.getElementById('embed-modal');
  const closeEmbedBtn = document.getElementById('close-embed-modal');
  const copyEmbedCodeBtn = document.getElementById('btn-copy-embed-code');
  const embedTextarea = document.getElementById('embed-code-textarea');

  if (embedBtn && embedModal) {
    embedBtn.addEventListener('click', () => {
      const code = `<iframe src="https://lovecalc.click/" width="100%" height="700" frameborder="0" style="border:none;border-radius:16px;box-shadow:0 10px 30px rgba(0,0,0,0.3);" title="Love Calculator"></iframe>\n<p style="font-size:12px;text-align:center;"><a href="https://lovecalc.click" target="_blank" rel="noopener">Powered by lovecalc.click</a></p>`;
      if (embedTextarea) embedTextarea.value = code;
      embedModal.classList.remove('hidden');
    });

    closeEmbedBtn?.addEventListener('click', () => {
      embedModal.classList.add('hidden');
    });

    copyEmbedCodeBtn?.addEventListener('click', () => {
      if (embedTextarea) {
        embedTextarea.select();
        navigator.clipboard.writeText(embedTextarea.value).then(() => {
          copyEmbedCodeBtn.textContent = '✅ Embed Code Copied!';
          setTimeout(() => {
            copyEmbedCodeBtn.textContent = 'Copy Code';
          }, 2500);
        });
      }
    });
  }

  // FAQ Accordion Handlers
  document.querySelectorAll('.faq-question').forEach((btn) => {
    btn.addEventListener('click', () => {
      const expanded = btn.getAttribute('aria-expanded') === 'true';
      btn.setAttribute('aria-expanded', !expanded);
      const answer = btn.nextElementSibling;
      if (answer) {
        answer.classList.toggle('active', !expanded);
      }
    });
  });

  // Check Deep-Link URL Params on Load
  const params = new URLSearchParams(window.location.search);
  const p1 = params.get('n1');
  const p2 = params.get('n2');
  const tab = params.get('tab') || 'names';

  if (p1 && p2) {
    const decoded1 = decodeURIComponent(p1);
    const decoded2 = decodeURIComponent(p2);

    // Switch to appropriate tab
    const tabTarget = document.querySelector(`[data-tab="${tab}-pane"]`);
    if (tabTarget) tabTarget.click();

    if (tab === 'names' || !tab) {
      const el1 = document.getElementById('calc-name1');
      const el2 = document.getElementById('calc-name2');
      if (el1 && el2) {
        el1.value = decoded1;
        el2.value = decoded2;
        setTimeout(() => {
          runCalculation(() => calculateNameLove(decoded1, decoded2), {
            name1: decoded1,
            name2: decoded2,
            type: 'names'
          });
        }, 300);
      }
    }
  }
});
