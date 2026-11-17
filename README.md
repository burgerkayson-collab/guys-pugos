# Build your OS ISO (no Linux needed)

1. Create a free GitHub account, then a **public** repository (public = free, roomy artifact storage).
2. Upload everything in this folder, **including .github/workflows/build.yml**,
   plus your pug picture named exactly `pug.jpg` in the top level.
3. Go to the **Actions** tab -> **Build ISO** -> **Run workflow**.
4. Wait ~45-90 minutes. Open the finished run and download the **iso** artifact (a zip containing the .iso).
5. Test it in VirtualBox first. Write to USB with Rufus or balenaEtcher.

To rename the OS, edit `OS_NAME` in `.github/workflows/build.yml`.
To see the pug on the installed system, run `pugos-systest --woof`.
