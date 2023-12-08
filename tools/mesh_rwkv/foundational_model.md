Hi! I want to thank you for your project.

Since you were able to get autoencoding working, I have a question. I was trying to get this to be encoded using your code. This is a mock-up of the syntax, but it's supposed to be a 3d-simplex (tetrahedron) translated by 1 meters.

If I am able to get the meshes in this form, we can take "off the shelf" training services like https://together.ai and start processing models from https://huggingface.co/datasets/allenai/objaverse-xl with translation, rotation (for like a basketball) and scale (affine transforms) to make a 3d mesh foundational model.

Can you provide some insight how to do this?

```json
[
    {
        "role": "system",
        "content": "This assistant can understand 3D models using the meshgpt-pytorch Unicode plane 15 codebook for 16384 triangles and the .ply 3d format."
    },
    {
        "role": "user",
        "content": "Please convert this to the meshgpt-pytorch codebook. ```ply\nformat ascii 1.0\nelement vertex 4\nproperty float x\nproperty float y\nproperty float z\nelement face 4\nproperty list uchar int vertex_index\nend_header\n0 0 0\n1 0 0\n0 1 0\n0 0 1\n3 0 1 2\n3 0 2 3\n3 0 1 3\n3 1 2 3```"
    },
    {
        "role": "assistant",
        "content": "􀀀􀀁􀀂􀀃"
    }
    {
        "role": "user",
        "content": "Please translate this mesh by 1 meter"
    },
    {
        "role": "assistant",
        "content": "􀀄􀀅􀀆􀀇"
    },
    {
        "role": "user",
        "content": "Can you convert it back to .ply format?"
    },
    {
        "role": "assistant",
        "content": "Sure, here is your translated mesh in .ply format: ```ply\nformat ascii 1.0\nelement vertex 4\nproperty float x\nproperty float y\nproperty float z\nelement face 4\nproperty list uchar int vertex_index\nend_header\n1 0 0\n2 0 0\n1 1 0\n1 0 1\n3 0 1 2\n3 0 2 3\n3 0 1 3\n3 1 2 3```"
    }
]
```

We can also map the codebook to `.ply` in chatml to be more obvious to the large language model since `.ply` support is very common.

```ply
ply
format ascii 1.0
element vertex 4
property float x
property float y
property float z
element face 4
property list uchar int vertex_index
end_header
0 0 0
1 0 0
0 1 0
0 0 1
3 0 1 2
3 0 2 3
3 0 1 3
3 1 2 3
```

See chatml description in https://huggingface.co/teknium/OpenHermes-2.5-Mistral-7B and

![.ply sample](https://github.com/lucidrains/meshgpt-pytorch/assets/32321/34cb4974-87d5-47f2-9574-6f70845ea719)