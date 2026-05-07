// Waveform bars
(function buildWaveform() {
  const container = document.getElementById('heroWaveform');
  if (!container) return;
  const heights = [30,50,70,45,90,60,40,80,55,35,75,50,65,45,85,60,40,70,50,80,35,60,90,45,70,55,40,75,50,65];
  heights.forEach((h, i) => {
    const bar = document.createElement('div');
    bar.className = 'waveform-bar' + (i % 3 === 0 ? ' active' : '');
    bar.style.height = h + '%';
    bar.style.animationDelay = (i * 0.06) + 's';
    container.appendChild(bar);
  });
})();

// Project card accent colors
document.querySelectorAll('.project-thumb').forEach(el => {
  const accent = el.dataset.accent;
  if (accent) el.style.setProperty('--thumb-accent', accent + '33');
});

// Navbar scroll effect
const navbar = document.getElementById('navbar');
window.addEventListener('scroll', () => {
  navbar.style.background = window.scrollY > 40
    ? 'rgba(13,13,13,0.97)'
    : 'rgba(13,13,13,0.85)';
});

// Scroll animations
const observer = new IntersectionObserver(entries => {
  entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); });
}, { threshold: 0.12 });

document.querySelectorAll('.project-card, .about-text, .about-skills, .contact-inner').forEach(el => {
  el.classList.add('fade-in');
  observer.observe(el);
});

// Play buttons (demo — no real audio)
document.querySelectorAll('.play-btn').forEach(btn => {
  let playing = false;
  let interval = null;
  const player = btn.closest('.audio-player');
  const fill = player.querySelector('.progress-fill');

  btn.addEventListener('click', () => {
    playing = !playing;

    // Toggle icon
    btn.innerHTML = playing
      ? '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/></svg>'
      : '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M8 5v14l11-7z"/></svg>';

    if (playing) {
      let progress = parseFloat(fill.style.width) || 0;
      interval = setInterval(() => {
        progress += 0.3;
        fill.style.width = Math.min(progress, 100) + '%';
        if (progress >= 100) {
          clearInterval(interval);
          playing = false;
          progress = 0;
          fill.style.width = '0%';
          btn.innerHTML = '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M8 5v14l11-7z"/></svg>';
        }
      }, 80);
    } else {
      clearInterval(interval);
    }
  });
});

// Contact form
document.getElementById('contactForm').addEventListener('submit', e => {
  e.preventDefault();
  const btn = e.target.querySelector('button[type="submit"]');
  btn.textContent = 'Message envoyé ✓';
  btn.style.background = '#4caf50';
  btn.disabled = true;
  setTimeout(() => {
    btn.textContent = 'Envoyer le message';
    btn.style.background = '';
    btn.disabled = false;
    e.target.reset();
  }, 3000);
});
