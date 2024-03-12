/**************************************************************************/
/*  test_qcp.h                                                            */
/**************************************************************************/
/*                         This file is part of:                          */
/*                             GODOT ENGINE                               */
/*                        https://godotengine.org                         */
/**************************************************************************/
/* Copyright (c) 2014-present Godot Engine contributors (see AUTHORS.md). */
/* Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.                  */
/*                                                                        */
/* Permission is hereby granted, free of charge, to any person obtaining  */
/* a copy of this software and associated documentation files (the        */
/* "Software"), to deal in the Software without restriction, including    */
/* without limitation the rights to use, copy, modify, merge, publish,    */
/* distribute, sublicense, and/or sell copies of the Software, and to     */
/* permit persons to whom the Software is furnished to do so, subject to  */
/* the following conditions:                                              */
/*                                                                        */
/* The above copyright notice and this permission notice shall be         */
/* included in all copies or substantial portions of the Software.        */
/*                                                                        */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
/**************************************************************************/

#ifndef TEST_QUATERNION_SWING_TWIST_H
#define TEST_QUATERNION_SWING_TWIST_H

#include "modules/many_bone_ik/src/ik_kusudama_3d.h"
#include "tests/test_macros.h"

namespace TestQuaternionSwingTwist {

TEST_CASE("[IKKusudama3D] get_swing_twist") {
	Quaternion rotation = Quaternion(1, 2, 3, 4).normalized();
	Vector3 axis = Vector3(0, 1, 0);
	Quaternion swing, twist;

	IKKusudama3D::get_swing_twist(rotation, axis, swing, twist);

	MESSAGE("Swing: " << swing);
	MESSAGE("Twist: " << twist);

	// Check if the swing and twist are normalized
	CHECK(Math::is_equal_approx(swing.length_squared(), 1.0));
	CHECK(Math::is_equal_approx(twist.length_squared(), 1.0));

	Vector3 rotation_axis = twist.get_axis();
	MESSAGE("Twist rotation axis: " << rotation_axis);

	// Check if the twist is along the given axis
	CHECK(Math::is_equal_approx(rotation_axis.x, 0.0));
	CHECK(Math::is_equal_approx(rotation_axis.y, 1.0));
	CHECK(Math::is_equal_approx(rotation_axis.z, 0.0));

	// Check if the original rotation is recovered when swing and twist are multiplied
	Quaternion recovered_rotation = (swing * twist).normalized();
	CHECK(Math::is_equal_approx(recovered_rotation.x, rotation.x));
	CHECK(Math::is_equal_approx(recovered_rotation.y, rotation.y));
	CHECK(Math::is_equal_approx(recovered_rotation.z, rotation.z));
	CHECK(Math::is_equal_approx(recovered_rotation.w, rotation.w));
}

TEST_CASE("[IKKusudama3D] get_swing_twist with zero rotation") {
	Quaternion rotation = Quaternion();
	Vector3 axis = Vector3(0, 1, 0);
	Quaternion swing, twist;

	IKKusudama3D::get_swing_twist(rotation, axis, swing, twist);

	// Check if the swing and twist are identity quaternions
	CHECK(swing.is_equal_approx(Quaternion()));
	CHECK(twist.is_equal_approx(Quaternion()));
}

TEST_CASE("[IKKusudama3D] get_swing_twist with zero axis") {
	Quaternion rotation = Quaternion(1, 2, 3, 4).normalized();
	Vector3 axis = Vector3();
	Quaternion swing, twist;

	IKKusudama3D::get_swing_twist(rotation, axis, swing, twist);

	// Check if the swing and twist are identity quaternions
	CHECK(swing.is_equal_approx(Quaternion()));
	CHECK(twist.is_equal_approx(Quaternion()));
}

TEST_CASE("[IKKusudama3D] get_swing_twist with rotation on axis") {
	Quaternion rotation = Quaternion(0, 1, 0, 0);
	Vector3 axis = Vector3(0, 1, 0);
	Quaternion swing, twist;

	IKKusudama3D::get_swing_twist(rotation, axis, swing, twist);

	// Check if the swing is an identity quaternion and twist equals the rotation
	CHECK(swing.is_equal_approx(Quaternion()));
	CHECK(twist.is_equal_approx(rotation));
}

TEST_CASE("[IKKusudama3D] get_swing_twist with negative axis") {
	Quaternion rotation = Quaternion(1, 2, 3, 4).normalized();
	Vector3 axis = Vector3(-1, -1, -1);
	Quaternion swing, twist;

	IKKusudama3D::get_swing_twist(rotation, axis, swing, twist);

	// Check if the swing and twist are normalized
	CHECK(Math::is_equal_approx(swing.length_squared(), 1.0));
	CHECK(Math::is_equal_approx(twist.length_squared(), 1.0));

	Vector3 rotation_axis = twist.get_axis().normalized();
	MESSAGE("Twist rotation axis: " << rotation_axis);

	// Check if the twist is along the given axis
	CHECK(Math::is_equal_approx(rotation_axis.x, -0.57735026918963));
	CHECK(Math::is_equal_approx(rotation_axis.y, -0.57735026918963));
	CHECK(Math::is_equal_approx(rotation_axis.z, -0.57735026918963));

	// Check if the original rotation is recovered when swing and twist are multiplied
	Quaternion recovered_rotation = (swing * twist).normalized();
	CHECK(Math::is_equal_approx(recovered_rotation.x, rotation.x));
	CHECK(Math::is_equal_approx(recovered_rotation.y, rotation.y));
	CHECK(Math::is_equal_approx(recovered_rotation.z, rotation.z));
	CHECK(Math::is_equal_approx(recovered_rotation.w, rotation.w));
}

TEST_CASE("[IKKusudama3D] get_swing_twist with non-normalized rotation") {
	Quaternion rotation = Quaternion(1, 2, 3, 4);
	Vector3 axis = Vector3(0, 1, 0);
	Quaternion swing, twist;

	IKKusudama3D::get_swing_twist(rotation, axis, swing, twist);

	// Check if the swing and twist are normalized
	CHECK(Math::is_equal_approx(swing.length_squared(), 1.0));
	CHECK(Math::is_equal_approx(twist.length_squared(), 1.0));

	Vector3 rotation_axis = twist.get_axis().normalized();
	MESSAGE("Twist rotation axis: " << rotation_axis);

	// Check if the twist is along the given axis
	CHECK(Math::is_equal_approx(rotation_axis.x, 0.0));
	CHECK(Math::is_equal_approx(rotation_axis.y, 1.0));
	CHECK(Math::is_equal_approx(rotation_axis.z, 0.0));

	// Check if the original rotation is recovered when swing and twist are multiplied
	Quaternion recovered_rotation = (swing * twist).normalized();
	CHECK(Math::is_equal_approx(recovered_rotation.x, rotation.normalized().x));
	CHECK(Math::is_equal_approx(recovered_rotation.y, rotation.normalized().y));
	CHECK(Math::is_equal_approx(recovered_rotation.z, rotation.normalized().z));
	CHECK(Math::is_equal_approx(recovered_rotation.w, rotation.normalized().w));
}
} // namespace TestQuaternionSwingTwist

#endif // TEST_QCP_H
