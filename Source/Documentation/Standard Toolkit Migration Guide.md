# How to migrate to the new namespaces

The purpose of this guide is to aid developers to transition over to the new namespaces. Please follow the steps as laid out below carefully!

## Step 1
Backup your existing project, ideally to another drive or create a new branch of your project if using GitHub or other source versioning solution. This step is important, as we do not accept responsibility of loss of data!

## Step 2
Either open the original project or the newly created branch in Visual Studio

## Step 3
Open a item in code view

## Step 4
Press **CTRL** + **H** to bring up the find/replace UI

## Step 5
In the *find* field, type in or replace any existing text with `ComponentFactory.` and leave the *replace* field blank. In the drop down box, select *Entire Solution*, then press **Replace All**

[]()

## Step 6
Build & deploy