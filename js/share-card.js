/**
 * Canvas Share Card Engine
 * Renders high-res, viral social share graphics for Instagram, WhatsApp, TikTok, X.
 */

class LoveShareCard {
  constructor() {
    this.canvas = document.createElement('canvas');
    this.ctx = this.canvas.getContext('2d');
  }

  generate({ name1, name2, percentage, tier, subscores, type = 'names' }) {
    const width = 1080;
    const height = 1350;
    this.canvas.width = width;
    this.canvas.height = height;
    const ctx = this.ctx;

    // Background: Radiant Romantic Dark Gradient
    const bgGrad = ctx.createLinearGradient(0, 0, width, height);
    bgGrad.addColorStop(0, '#10071c');
    bgGrad.addColorStop(0.45, '#230b2c');
    bgGrad.addColorStop(0.85, '#350a2e');
    bgGrad.addColorStop(1, '#15061c');
    ctx.fillStyle = bgGrad;
    ctx.fillRect(0, 0, width, height);

    // Subtle Glowing Orbs in Corners
    this._drawGlowOrb(ctx, 150, 150, 350, 'rgba(255, 42, 109, 0.25)');
    this._drawGlowOrb(ctx, width - 150, height - 200, 400, 'rgba(155, 93, 229, 0.22)');
    this._drawGlowOrb(ctx, width / 2, height / 2, 450, 'rgba(255, 94, 126, 0.15)');

    // Outer Decorative Border
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.12)';
    ctx.lineWidth = 4;
    this._roundRect(ctx, 50, 50, width - 100, height - 100, 40, false, true);

    // Inner Glass Card
    ctx.fillStyle = 'rgba(255, 255, 255, 0.04)';
    this._roundRect(ctx, 80, 80, width - 160, height - 160, 32, true, false);

    // Top Header Badge
    ctx.fillStyle = 'rgba(255, 42, 109, 0.2)';
    this._roundRect(ctx, width / 2 - 200, 130, 400, 56, 28, true, false);
    ctx.strokeStyle = '#ff2a6d';
    ctx.lineWidth = 2;
    this._roundRect(ctx, width / 2 - 200, 130, 400, 56, 28, false, true);

    ctx.fillStyle = '#ffd166';
    ctx.font = 'bold 24px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.textAlign = 'center';
    ctx.fillText('✨ OFFICIAL LOVE COMPATIBILITY ✨', width / 2, 167);

    // Couple Names
    ctx.fillStyle = '#ffffff';
    ctx.font = 'bold 56px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    const coupleText = `${name1}  ❤️  ${name2}`;
    ctx.fillText(this._truncate(coupleText, 28), width / 2, 270);

    // Love Score Circle / Glow
    const circleY = 530;
    this._drawGlowOrb(ctx, width / 2, circleY, 220, 'rgba(255, 42, 109, 0.35)');

    // Circular Border
    ctx.beginPath();
    ctx.arc(width / 2, circleY, 170, 0, Math.PI * 2);
    ctx.lineWidth = 14;
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.1)';
    ctx.stroke();

    // Progress Arc
    const startAngle = -Math.PI / 2;
    const endAngle = startAngle + (Math.PI * 2 * (percentage / 100));
    const arcGrad = ctx.createLinearGradient(width / 2 - 170, circleY - 170, width / 2 + 170, circleY + 170);
    arcGrad.addColorStop(0, '#ff2a6d');
    arcGrad.addColorStop(0.5, '#ff5e7e');
    arcGrad.addColorStop(1, '#ffd166');

    ctx.beginPath();
    ctx.arc(width / 2, circleY, 170, startAngle, endAngle);
    ctx.lineWidth = 18;
    ctx.lineCap = 'round';
    ctx.strokeStyle = arcGrad;
    ctx.stroke();

    // Percentage Text
    ctx.fillStyle = '#ffffff';
    ctx.font = 'bold 110px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillText(`${percentage}%`, width / 2, circleY + 32);

    ctx.fillStyle = '#ff99c8';
    ctx.font = '600 24px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillText('MATCH SCORE', width / 2, circleY + 80);

    // Tier Title
    ctx.fillStyle = '#ffeaa7';
    ctx.font = 'bold 42px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillText(tier || 'Cosmic Harmony', width / 2, 770);

    // Sub-Scores Grid
    const startY = 840;
    const scores = subscores || [
      { label: 'Romance & Chemistry', score: percentage },
      { label: 'Communication Synergy', score: Math.min(100, percentage + 4) },
      { label: 'Emotional Trust', score: Math.max(50, percentage - 6) },
      { label: 'Long-term Potential', score: percentage }
    ];

    scores.forEach((s, idx) => {
      const y = startY + idx * 76;
      ctx.fillStyle = '#e2e8f0';
      ctx.font = '500 26px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
      ctx.textAlign = 'left';
      ctx.fillText(s.label, 160, y);

      ctx.textAlign = 'right';
      ctx.fillStyle = '#ffd166';
      ctx.font = 'bold 26px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
      ctx.fillText(`${s.score}%`, width - 160, y);

      // Bar Background
      ctx.fillStyle = 'rgba(255, 255, 255, 0.1)';
      this._roundRect(ctx, 160, y + 12, width - 320, 16, 8, true, false);

      // Bar Progress
      const barGrad = ctx.createLinearGradient(160, y + 12, 160 + (width - 320), y + 12);
      barGrad.addColorStop(0, '#ff2a6d');
      barGrad.addColorStop(1, '#ff99c8');
      ctx.fillStyle = barGrad;
      const barWidth = Math.max(16, ((width - 320) * s.score) / 100);
      this._roundRect(ctx, 160, y + 12, barWidth, 16, 8, true, false);
    });

    // Watermark / Brand Footer
    ctx.textAlign = 'center';
    ctx.fillStyle = '#a0aec0';
    ctx.font = '500 22px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    ctx.fillText('Calculate yours at lovecalc.click ❤️ True Love Match', width / 2, 1220);

    return this.canvas.toDataURL('image/png');
  }

  _drawGlowOrb(ctx, x, y, radius, color) {
    ctx.save();
    const radGrad = ctx.createRadialGradient(x, y, 0, x, y, radius);
    radGrad.addColorStop(0, color);
    radGrad.addColorStop(1, 'rgba(0, 0, 0, 0)');
    ctx.fillStyle = radGrad;
    ctx.beginPath();
    ctx.arc(x, y, radius, 0, Math.PI * 2);
    ctx.fill();
    ctx.restore();
  }

  _roundRect(ctx, x, y, width, height, radius, fill, stroke) {
    ctx.beginPath();
    ctx.moveTo(x + radius, y);
    ctx.lineTo(x + width - radius, y);
    ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
    ctx.lineTo(x + width, y + height - radius);
    ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
    ctx.lineTo(x + radius, y + height);
    ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
    ctx.lineTo(x, y + radius);
    ctx.quadraticCurveTo(x, y, x + radius, y);
    ctx.closePath();
    if (fill) ctx.fill();
    if (stroke) ctx.stroke();
  }

  _truncate(str, maxLen) {
    if (str.length <= maxLen) return str;
    return str.substring(0, maxLen - 3) + '...';
  }

  async downloadOrShare(data, fileName = 'love-compatibility-card.png') {
    const dataUrl = this.generate(data);

    // Convert dataUrl to Blob for Web Share API
    const res = await fetch(dataUrl);
    const blob = await res.blob();
    const file = new File([blob], fileName, { type: 'image/png' });

    if (navigator.canShare && navigator.canShare({ files: [file] })) {
      try {
        await navigator.share({
          files: [file],
          title: `${data.name1} & ${data.name2} Love Test - ${data.percentage}%`,
          text: `Check out our ${data.percentage}% match on the Love Calculator! Calculate yours: https://lovecalc.click`
        });
        return { shared: true };
      } catch (err) {
        if (err.name !== 'AbortError') {
          console.warn('Share error fallback to download', err);
        }
      }
    }

    // Fallback: Direct Download
    const a = document.createElement('a');
    a.href = dataUrl;
    a.download = fileName;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    return { downloaded: true, dataUrl };
  }
}

window.loveCardEngine = new LoveShareCard();
