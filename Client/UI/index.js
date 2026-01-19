Events.Subscribe('UpdateAmmo', (ammo) => {
  document.querySelector('#ammoCount').innerText = ammo;
})
