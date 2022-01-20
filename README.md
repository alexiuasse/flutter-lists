# Flutter Lists

A Simple Flutter project that create and manage lists.

It uses sqlite to store the lists.

## Check it out

This app is available on the PlayStore just search *Minhas Listas*. For now just a PT-BR version is available. 
https://play.google.com/store/apps/details?id=com.br.iuasse.lists.lists

## How to create a new version

The TAG must follow the pattern 0.0.0+0 where the +0 is the version of the application to be deployed on PlayStore

```
git checkout master && git pull
git merge --no-ff develop
git tag -a TAG
git checkout develop && git merge --no-ff TAG
git push origin develop master TAG
```

## Future development

**Not in sequencial order**

- Develop a custom theme
- Develop a web version
- Deploy web version on Firebase Hosting
- Create a backend project to save user data (probably Django or maybe Firebase?)
    - Save data as a json
- Deploy the backend on Heroku

## Contact

For contact send an email to: alexiuasse@gmail.com