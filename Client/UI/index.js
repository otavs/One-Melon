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
