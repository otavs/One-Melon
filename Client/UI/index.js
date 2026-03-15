Events.Subscribe('UpdateAmmo', (ammo) => {
  document.querySelector('#ammoCount').innerText = ammo
})

const powerUpIcons = {
  Jump: '⚡',
  Speed: '💨',
}

const activePowerUps = {}

Events.Subscribe('PowerUpActivated', (name, label, duration) => {
  // Clear existing countdown for this powerup if re-picked
  if (activePowerUps[name]) {
    clearInterval(activePowerUps[name].interval)
    activePowerUps[name].element.remove()
    delete activePowerUps[name]
  }

  const icon = powerUpIcons[name] || '✨'
  let timeLeft = duration

  const el = document.createElement('div')
  el.className = 'powerup'

  const update = () => {
    el.textContent = `${icon} ${label} ${timeLeft}s`
  }
  update()

  const combo = document.querySelector('#powerups .combo')
  document.getElementById('powerups').insertBefore(el, combo || null)

  const interval = setInterval(() => {
    timeLeft--
    if (timeLeft <= 0) {
      clearInterval(interval)
      el.remove()
      delete activePowerUps[name]
    } else {
      update()
    }
  }, 1000)

  activePowerUps[name] = { interval, element: el }
})

Events.Subscribe('KillFeed', (killer, victim, duration) => {
  const el = document.createElement('div')
  el.className = 'kill'
  el.innerHTML = `<span class="killer">${killer}</span> eliminated <span class="victim">${victim}</span>`
  document.getElementById('killfeed').appendChild(el)

  setTimeout(() => el.remove(), duration * 1000)
})

let localPlayerId = null

Events.Subscribe('SetLocalPlayer', (id) => {
  localPlayerId = id
})

Events.Subscribe('UpdateCombo', (combo) => {
  const el = document.querySelector('#powerups .combo')
  if (combo > 0) {
    el.textContent = `Combo x${combo}`
    el.style.display = ''
  } else {
    el.style.display = 'none'
  }
})

function escHtml(s) {
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
}

Events.Subscribe('UpdateScoreboard', (rawEntries, maxTop) => {
  const entries = Array.isArray(rawEntries)
    ? rawEntries
    : Object.values(rawEntries)
  const total = entries.length
  const myIdx = localPlayerId
    ? entries.findIndex((e) => e.id === localPlayerId)
    : -1

  const rows = []
  if (total <= maxTop || (myIdx !== -1 && myIdx < maxTop)) {
    const topEnd = Math.min(maxTop, total)
    for (let i = 0; i < topEnd; i++) rows.push({ type: 'entry', idx: i })
    if (myIdx >= topEnd) {
      rows.push({ type: 'sep' })
      const winStart = Math.max(topEnd, myIdx - 2)
      const winEnd = Math.min(total - 1, myIdx + 2)
      for (let i = winStart; i <= winEnd; i++)
        rows.push({ type: 'entry', idx: i })
      if (winEnd < total - 1) rows.push({ type: 'sep' })
    } else if (total > topEnd) {
      rows.push({ type: 'sep' })
    }
  } else {
    for (let i = 0; i < maxTop; i++) rows.push({ type: 'entry', idx: i })
    rows.push({ type: 'sep' })
    const winStart = Math.max(maxTop, myIdx - 2)
    const winEnd = Math.min(total - 1, myIdx + 2)
    for (let i = winStart; i <= winEnd; i++)
      rows.push({ type: 'entry', idx: i })
    if (winEnd < total - 1) rows.push({ type: 'sep' })
  }

  const lb = document.getElementById('leaderboard')
  lb.querySelectorAll('.leader-row, .leader-sep').forEach((el) => el.remove())

  for (const row of rows) {
    if (row.type === 'sep') {
      const sep = document.createElement('div')
      sep.className = 'leader-sep'
      sep.textContent = '···'
      lb.appendChild(sep)
    } else {
      const entry = entries[row.idx]
      const isMe = entry.id === localPlayerId
      const el = document.createElement('div')
      el.className = 'leader-row' + (isMe ? ' me' : '')
      const rank = document.createElement('span')
      rank.className = 'rank'
      rank.textContent = `#${row.idx + 1}`
      const img = document.createElement('img')
      img.src = entry.icon
      const name = document.createElement('span')
      name.textContent = entry.name
      const pts = document.createElement('span')
      pts.className = 'points'
      pts.textContent = entry.kills
      el.append(rank, img, name, pts)
      lb.appendChild(el)
    }
  }
})
