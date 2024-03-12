#include "modules/many_bone_ik/src/ik_bone_segment_3d.h"
#include "tests/test_macros.h"

namespace TestQuaternionClampToQuadranceAngle {

TEST_CASE("[IKBoneSegment3D] clamp_to_quadrance_angle") {
	Quaternion rotation = Quaternion(1, 2, 3, 4).normalized();
	double cos_half_angle = 0.5;

	IKBoneSegment3D bone;
	Quaternion clamped_rotation = bone.clamp_to_quadrance_angle(rotation, cos_half_angle);

	MESSAGE("Original Rotation: " << rotation);
	MESSAGE("Clamped Rotation: " << clamped_rotation);

	// Check if the clamped rotation is normalized
	CHECK(Math::is_equal_approx(clamped_rotation.length_squared(), 1.0));

	// Check if the clamped rotation does not exceed the specified angle
	double cos_angle = 2 * cos_half_angle * cos_half_angle - 1;
	double dot_product = rotation.dot(clamped_rotation);
	CHECK(dot_product >= cos_angle);
}

} // namespace TestQuaternionClampToQuadranceAngle
