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
