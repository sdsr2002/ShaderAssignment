using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour
{
    public Vector3 rotation;
    public float _speed;
    private float speed => _speed * Time.deltaTime;
    private void Update()
    { 
        transform.rotation *= Quaternion.Euler(rotation.x * speed, rotation.y * speed, rotation.z * speed);
    }
}
