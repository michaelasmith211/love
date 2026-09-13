/**
 * Romantic Particle Canvas Engine
 * Floating hearts, soft sparkles, and interactive tap bursts.
 */

class RomanticParticles {
  constructor(canvasId) {
    this.canvas = document.getElementById(canvasId);
    if (!this.canvas) return;
    this.ctx = this.canvas.getContext('2d');
    this.particles = [];
    this.maxParticles = window.innerWidth < 768 ? 24 : 45;
    this.animationFrame = null;
    this.isVisible = true;

    // Check prefers-reduced-motion
    this.reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (this.reducedMotion) return;

    this.resize();
    this.init();
    this.bindEvents();
    this.animate();
  }

  resize() {
    this.width = this.canvas.width = window.innerWidth;
    this.height = this.canvas.height = window.innerHeight;
  }

  init() {
    this.particles = [];
    for (let i = 0; i < this.maxParticles; i++) {
      this.particles.push(this.createParticle(false));
    }
  }

  createParticle(isBurst = false, burstX = 0, burstY = 0) {
    const isHeart = Math.random() > 0.45;
    const colors = ['#ff2a6d', '#ff5e7e', '#ff99c8', '#9b5de5', '#ffd166', '#f15bb5'];
    const color = colors[Math.floor(Math.random() * colors.length)];

    if (isBurst) {
      const angle = Math.random() * Math.PI * 2;
      const speed = Math.random() * 3 + 1.5;
      return {
        x: burstX,
        y: burstY,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed - 1.5,
        size: Math.random() * 12 + 8,
        color,
        isHeart: true,
        alpha: 1,
        fadeSpeed: Math.random() * 0.02 + 0.015,
        rotation: Math.random() * 360,
        rotationSpeed: (Math.random() - 0.5) * 4,
        isBurst: true
      };
    }

    return {
      x: Math.random() * this.width,
      y: Math.random() * this.height,
      vx: (Math.random() - 0.5) * 0.5,
      vy: -(Math.random() * 0.6 + 0.3),
      size: isHeart ? Math.random() * 14 + 10 : Math.random() * 3 + 2,
      color,
      isHeart,
      alpha: Math.random() * 0.5 + 0.2,
      fadeSpeed: (Math.random() - 0.5) * 0.005,
      rotation: Math.random() * 360,
      rotationSpeed: (Math.random() - 0.5) * 1.5,
      isBurst: false
    };
  }

  drawHeart(x, y, size, color, alpha, rotation) {
    this.ctx.save();
    this.ctx.translate(x, y);
    this.ctx.rotate((rotation * Math.PI) / 180);
    this.ctx.globalAlpha = Math.max(0, Math.min(1, alpha));
    this.ctx.fillStyle = color;

    // Draw SVG-like heart
    const s = size / 24;
    this.ctx.beginPath();
    this.ctx.moveTo(0, 0);
    this.ctx.bezierCurveTo(-12 * s, -12 * s, -20 * s, 4 * s, 0, 16 * s);
    this.ctx.bezierCurveTo(20 * s, 4 * s, 12 * s, -12 * s, 0, 0);
    this.ctx.fill();
    this.ctx.restore();
  }

  drawStar(x, y, size, color, alpha) {
    this.ctx.save();
    this.ctx.translate(x, y);
    this.ctx.globalAlpha = Math.max(0, Math.min(1, alpha));
    this.ctx.fillStyle = color;
    this.ctx.beginPath();
    this.ctx.arc(0, 0, size, 0, Math.PI * 2);
    this.ctx.fill();
    this.ctx.restore();
  }

  animate() {
    if (!this.isVisible) return;

    this.ctx.clearRect(0, 0, this.width, this.height);

    for (let i = this.particles.length - 1; i >= 0; i--) {
      const p = this.particles[i];

      p.x += p.vx;
      p.y += p.vy;
      p.rotation += p.rotationSpeed;

      if (p.isBurst) {
        p.alpha -= p.fadeSpeed;
        p.vy += 0.05; // gentle gravity
        if (p.alpha <= 0) {
          this.particles.splice(i, 1);
          continue;
        }
      } else {
        p.alpha += p.fadeSpeed;
        if (p.alpha > 0.7 || p.alpha < 0.2) p.fadeSpeed = -p.fadeSpeed;

        // Reset if floated above screen
        if (p.y < -30) {
          p.y = this.height + 20;
          p.x = Math.random() * this.width;
        }
        if (p.x < -20) p.x = this.width + 20;
        if (p.x > this.width + 20) p.x = -20;
      }

      if (p.isHeart) {
        this.drawHeart(p.x, p.y, p.size, p.color, p.alpha, p.rotation);
      } else {
        this.drawStar(p.x, p.y, p.size, p.color, p.alpha);
      }
    }

    this.animationFrame = requestAnimationFrame(() => this.animate());
  }

  burst(x, y, count = 12) {
    if (this.reducedMotion) return;
    for (let i = 0; i < count; i++) {
      this.particles.push(this.createParticle(true, x, y));
    }
  }

  bindEvents() {
    window.addEventListener('resize', () => this.resize(), { passive: true });

    document.addEventListener('click', (e) => {
      // Don't burst on input or button to avoid UI interference
      if (['INPUT', 'BUTTON', 'A', 'SELECT'].includes(e.target.tagName)) return;
      this.burst(e.clientX, e.clientY, 8);
    }, { passive: true });

    // Pause when page is hidden
    document.addEventListener('visibilitychange', () => {
      this.isVisible = !document.hidden;
      if (this.isVisible) {
        this.animate();
      } else if (this.animationFrame) {
        cancelAnimationFrame(this.animationFrame);
      }
    });
  }
}

document.addEventListener('DOMContentLoaded', () => {
  window.particleSystem = new RomanticParticles('ambient-canvas');
});
