# Frame layout

The frame is divided into a 80×45 grid of squares.

Each square has a power-of-two size under normal video resolution, and it is filled with a single color when the data exists.

Horizontally adjacent squares are paired into a *slot*, which encodes a real number between ±1
(encoding scheme will be introduced in later sections).

As a result, **each frame represents a 40×45 matrix of real numbers between ±1**.

The slots are indexed from top to down, left to right, starting from 0. For example, slots in the first three columns are 0~44, 45~89, 90~134.

Currently, a humanoid avatar occupies the first three columns.

| Slot  | Use                  | Slot  | Use           | Slot    | Use         |
|:------|:---------------------|:------|:--------------|:--------|:------------|
| 0~2   | Hips (position high) | 45~47 | LeftShoulder  | 90~93   | LeftThumb   |
| 3~5   | Hips (position low)  | 48~50 | RightShoulder | 94~97   | LeftIndex   |
| 6~8   | Hips (scaled y-axis) | 51~53 | LeftUpperArm  | 98~101  | LeftMiddle  |
| 9~11  | Hips (scaled z-axis) | 54~56 | RightUpperArm | 102~105 | LeftRing    |
| 12~14 | Spine                | 57~59 | LeftLowerArm  | 106~109 | LeftLittle  |
| 15~17 | Chest                | 60~62 | RightLowerArm | 110~113 | RightThumb  |
| 18~20 | UpperChest           | 63~65 | LeftHand      | 114~117 | RightIndex  |
| 21~23 | Neck                 | 66~68 | RightHand     | 118~121 | RightMiddle |
| 24~26 | Head                 | 69    | LeftToes      | 122~125 | RightRing   |
| 27~29 | LeftUpperLeg         | 70    | RightToes     | 126~129 | RightLittle |
| 30~32 | RightUpperLeg        | 71~72 | LeftEye       |         |             |
| 33~35 | LeftLowerLeg         | 73~74 | RightEye      |         |             |
| 36~38 | RightLowerLeg        | 75~76 | Jaw           |         |             |
| 39~41 | LeftFoot             |       |               |         |             |
| 42~44 | RightFoot            |       |               |         |             |

Most slots store swing-twist angles, in the order of XYZ, scaled from [-180°, +180°] to [-1, +1].

* Finger angles are stored in the order of Proximal YZ, Intermediate Z, Distal Z.
* LeftEye/RightEye angles are stored in the order of YZ.
* LeftToes/RightToes have only Z angles.

# Special handling of Hips

Hips bone is an exception because it can translate and rotate freely, relative to the origin of recording space. It also need to encode _avatar scale_ (the height of Hips bone in T-pose) for retargeting.

Its position is scaled down by a factor of 2, encoded into two parts which approximate integral & fractional parts (see encoding scheme section), and put separately into slot 0~2 and 3~5. The scaling factor is chosen so that the normal range of motion will have integral part equal zero, which makes possible for sloppy decoders to skip decoding the integral part.

Its rotation is represented by rotation matrix to avoid discontinuity in swing-twist or quaternion representation. Slot 6~8 and 9~11 store the second and third column of the rotation matrix, i.e. its y-axis and z-axis, scaled appropriately so that `length(scaled y-axis)/length(scaled z-axis)` equals the avatar scale.