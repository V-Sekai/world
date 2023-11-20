# Guidelines

## Characters

The objective of Shot Generator is to keep the setup of a shot extremely simple. Therefore, the characters are designed with the silhouette of the character in mind - a shape that upon quick glance, you can tell:

- Gender
- Age
- Body type
- Height
- Pose

### The Models

Female and Male bone proportions and body shape are different so they needed to be their own models. Additionally, adult and youth bone proportions and body shape are different so they needed to be their own models. [ Male, Female ] x [ Adult, Youth] = 4 models.

We accomplished this by creating 4 main models:

- Female - Adult
- Female - Youth
- Male - Adult
- Male - Youth

![Models](https://user-images.githubusercontent.com/441117/50731218-9b1b4680-112c-11e9-844f-e950ba16b6ec.png)

#### Morph targets (Blend Shapes)

Body type is accomplished through morph targets. Morph targets or Blend Shapes are modifications to existing geometry. They have the same exact vertices, they are just in different locations. So you can easily mix/blend between 1 or more morph targets to get interesting model shapes. We decided on 4 prototypical body shapes:

- Mesomorph (Medium Build) [default]  
  ![Mesomorph](https://user-images.githubusercontent.com/441117/50731145-7bcfe980-112b-11e9-86c5-2157ef20b45f.png)
- Ectomorph (Skinny)  
  ![Ectomorph](https://user-images.githubusercontent.com/441117/50731176-fc8ee580-112b-11e9-9102-a83692533551.png)
- Muscular  
  ![Muscular](https://user-images.githubusercontent.com/441117/50731184-221bef00-112c-11e9-915f-b7f086ee2ba6.png)
- Obese  
  ![Obese](https://user-images.githubusercontent.com/441117/50731190-3eb82700-112c-11e9-9978-9b349252ba2c.png)

By blending a combination, you can make many body shapes:

- Skinny athletic person (Ectomorph: 0.7, Muscular: 0.4)  
  ![Skinny Athletic](https://user-images.githubusercontent.com/441117/50731203-6f985c00-112c-11e9-96e8-4a84655810d9.png)
- Stocky person (Obese: 0.5, Muscular: 0.5)  
  ![Stocky](https://user-images.githubusercontent.com/441117/50731207-74f5a680-112c-11e9-8428-4b7f3ff38261.png)

#### Armature (Skeleton Structure)

The mesh of the model is rigged/skinned mostly by Mixamo's online tool. We use their standard 65 bone Standard Skeleton, which includes individual fingers. The bone names are named like: mixamorig:LeftUpLeg

![Armature](https://user-images.githubusercontent.com/441117/50726908-49999a00-10e1-11e9-8bbc-71aefa5df0ac.png)

#### Scale (Height)

1 3D Unit = 1 Meter = 3.28084 Feet = 1.09361 Yards

Godot Engine where we do scaling and it uses 1 meters scale.

Even though a 3D unit is arbitrary, the world has loosely agreed that this is the preferred conversion.

Shot Generator automatically scales the models to normalize them. However the scales for the standard model heights are:

- Male - Adult: 1.8 meters
- Female - Adult: 1.625 meters
- Female - Youth: 1.6 meters
- Male - Youth: 1.6 meters

Height is controlled by scaling the armature/skeleton to the appropriate height. The only exception is that the head bone does not scale. As people are taller and shorter, their heads are roughly the same size. It is true that skulls vary in size. The scale of the head can be overridden.

#### Pose

Posing is done in the engine. This is by rotating bones, and saving a preset of all the bone rotations. There are no limitations on how you can rotate bones. Go crazy.

#### UV / Texture

There is one material and one texture. It's adjacent to the model in the textures folder.
