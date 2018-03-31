using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
public class Cube : MonoBehaviour {

	public GameObject prefab;
	public int CubeNum;
	public int _x;
	public int _y;
	public int _z;
	float rotateY = 0;
	float RADIAN = Mathf.PI / 180;
	Vector3[] cubePositions;

	void Start () {
		for (int i = 0; i < CubeNum; i++) {
			float radius = Random.Range(0.0f, 100);
			float rad = Random.Range(0, 360) * RADIAN;
			float rad2 = Random.Range(0, 360) * RADIAN;

			Vector3 pos = new Vector3(
				Mathf.Cos(rad) * Mathf.Cos(rad2) * (radius),
				Mathf.Cos(rad) * Mathf.Sin(rad2) * (radius),
				Mathf.Sin(rad) * (radius)
			);

			GameObject instance = Instantiate (prefab, pos, Quaternion.identity);
			instance.transform.parent = gameObject.transform;
		}

		cubePositions = new Vector3[CubeNum];
		int length = 10;

		for (int x = 0; x < _x; x++) {
			for (int y = 0; y < _y; y++) {
				for (int z = 0; z < _z; z++) {
					cubePositions[x * _y * _z + y * _z + z] = new Vector3(x,y,z);
				}
			}
		}
	}
	
	void Update () {
		gameObject.transform.rotation = Quaternion.Euler(0, rotateY, 0);
		rotateY ++;

		if (Input.GetKey(KeyCode.M)) {
			Move();
		}
	}

	void Move () {
		for (int i = 0; i < CubeNum; i++) {
			Transform child = transform.GetChild(i);
			child.transform.DOMove(cubePositions[i], 0.3f);
		}
	}
}
